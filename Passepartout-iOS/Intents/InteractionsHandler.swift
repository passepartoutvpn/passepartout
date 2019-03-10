//
//  InteractionsHandler.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 3/8/19.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Intents
import SwiftyBeaver

private let log = SwiftyBeaver.self

extension Notification.Name {
    static let IntentDidUpdateService = Notification.Name("IntentDidUpdateService")
}

@available(iOS 12, *)
class InteractionsHandler {
    private class Groups {
        static let vpn = "VPN"
        
        static let trust = "Trust"
    }
    
    static func donateConnection(with profile: ConnectionProfile) {
        let profileKey = ProfileKey(profile)
        let genericIntent: INIntent
        
        if let provider = profile as? ProviderConnectionProfile, let pool = provider.pool {
            let intent = MoveToLocationIntent()
            intent.providerId = profile.id
            intent.poolId = pool.id
            intent.poolName = pool.name
            genericIntent = intent
        } else {
            let intent = ConnectVPNIntent()
            intent.context = profileKey.context.rawValue
            intent.profileId = profileKey.id
            genericIntent = intent
        }
        
        let interaction = INInteraction(intent: genericIntent, response: nil)
        interaction.groupIdentifier = profileKey.rawValue
        interaction.donateAndLog()
    }
    
    static func donateEnableVPN() {
        let intent = EnableVPNIntent()
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.groupIdentifier = Groups.vpn
        interaction.donateAndLog()
    }
    
    static func donateDisableVPN() {
        let intent = DisableVPNIntent()
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.groupIdentifier = Groups.vpn
        interaction.donateAndLog()
    }
    
    static func donateTrustCurrentNetwork() {
        let intent = TrustCurrentNetworkIntent()

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }

    static func donateUntrustCurrentNetwork() {
        let intent = UntrustCurrentNetworkIntent()
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }
    
    static func donateTrustCellularNetwork() {
        let intent = TrustCellularNetworkIntent()
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }
    
    static func donateUntrustCellularNetwork() {
        let intent = UntrustCellularNetworkIntent()
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }
    
    //
    
    static func handleInteraction(_ interaction: INInteraction) {
        if let custom = interaction.intent as? ConnectVPNIntent {
            handleConnectVPN(custom, interaction: interaction)
        } else if let custom = interaction.intent as? EnableVPNIntent {
            handleEnableVPN(custom, interaction: interaction)
        } else if let custom = interaction.intent as? DisableVPNIntent {
            handleDisableVPN(custom, interaction: interaction)
        } else if let custom = interaction.intent as? MoveToLocationIntent {
            handleMoveToLocation(custom, interaction: interaction)
        } else if let _ = interaction.intent as? TrustCurrentNetworkIntent {
            handleCurrentNetwork(trust: true, interaction: interaction)
        } else if let _ = interaction.intent as? UntrustCurrentNetworkIntent {
            handleCurrentNetwork(trust: false, interaction: interaction)
        } else if let _ = interaction.intent as? TrustCellularNetworkIntent {
            handleCellularNetwork(trust: true, interaction: interaction)
        } else if let _ = interaction.intent as? UntrustCellularNetworkIntent {
            handleCellularNetwork(trust: false, interaction: interaction)
        }
    }
    
    private static func handleConnectVPN(_ intent: ConnectVPNIntent, interaction: INInteraction) {
        guard let contextValue = intent.context, let context = Context(rawValue: contextValue), let id = intent.profileId else {
            INInteraction.delete(with: [interaction.identifier], completion: nil)
            return
        }
        let profileKey = ProfileKey(context, id)
        log.info("Connect to profile \(profileKey)")
        
        let service = TransientStore.shared.service
        let vpn = VPN.shared
        guard !(service.isActiveProfile(profileKey) && (vpn.status == .connected)) else {
            log.info("Profile is already active and connected")
            return
        }

        guard let profile = service.profile(withContext: context, id: id) else {
            return
        }
        service.activateProfile(profile)
        refreshVPN(service: service, doReconnect: true)
    }

    private static func handleMoveToLocation(_ intent: MoveToLocationIntent, interaction: INInteraction) {
        guard let providerId = intent.providerId, let poolId = intent.poolId else {
            return
        }
        let service = TransientStore.shared.service
        guard let providerProfile = service.profile(withContext: .provider, id: providerId) as? ProviderConnectionProfile else {
            return
        }
        log.info("Move to provider \(providerId) @ [\(poolId)]")
        
        let vpn = VPN.shared
        guard !(service.isActiveProfile(providerProfile) && (providerProfile.poolId == poolId) && (vpn.status == .connected)) else {
            log.info("Profile is already active and connected to \(poolId)")
            return
        }

        providerProfile.poolId = poolId
        service.activateProfile(providerProfile)
        refreshVPN(service: service, doReconnect: true)
    }

    private static func handleEnableVPN(_ intent: EnableVPNIntent, interaction: INInteraction) {
        let service = TransientStore.shared.service
        log.info("Enabling VPN...")
        refreshVPN(service: service, doReconnect: true)
    }
    
    private static func handleDisableVPN(_ intent: DisableVPNIntent, interaction: INInteraction) {
        VPN.shared.disconnect { (error) in
            notifyServiceController()
        }
    }
    
    private static func handleCurrentNetwork(trust: Bool, interaction: INInteraction) {
        guard let currentWifi = Utils.currentWifiNetworkName() else {
            return
        }
        let service = TransientStore.shared.service
        service.preferences.trustedWifis[currentWifi] = trust
        TransientStore.shared.serialize(withProfiles: false)
        
        refreshVPN(service: service, doReconnect: false)
    }

    private static func handleCellularNetwork(trust: Bool, interaction: INInteraction) {
        guard Utils.hasCellularData() else {
            return
        }
        let service = TransientStore.shared.service
        service.preferences.trustsMobileNetwork = trust
        TransientStore.shared.serialize(withProfiles: false)
        
        refreshVPN(service: service, doReconnect: false)
    }

    private static func refreshVPN(service: ConnectionService, doReconnect: Bool) {
        let configuration: VPNConfiguration
        do {
            configuration = try service.vpnConfiguration()
        } catch let e {
            log.error("Unable to build VPN configuration: \(e)")
            notifyServiceController()
            return
        }
        
        let vpn = VPN.shared
        if doReconnect {
            vpn.reconnect(configuration: configuration) { (error) in
                notifyServiceController()
            }
        } else {
            vpn.install(configuration: configuration) { (error) in
                notifyServiceController()
            }
        }
    }
    
    //

    static func forgetProfile(withKey profileKey: ProfileKey) {
        INInteraction.delete(with: profileKey.rawValue) { (error) in
            if let error = error {
                log.error("Unable to forget interactions: \(error)")
                return
            }
            log.debug("Removed profile \(profileKey) interactions")
        }
    }
    
    //
    
    private static func notifyServiceController() {
        NotificationCenter.default.post(name: .IntentDidUpdateService, object: nil)
    }
}

private extension INInteraction {
    func donateAndLog() {
        donate { (error) in
            if let error = error {
                log.error("Unable to donate interaction: \(error)")
            }
            log.debug("Donated \(self.intent)")
        }
    }
}
