//
//  IntentDispatcher.swift
//  Passepartout
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

public extension Notification.Name {
    static let IntentDidUpdateService = Notification.Name("IntentDidUpdateService")
}

@available(iOS 12, *)
public class IntentDispatcher {
    private class Groups {
        static let vpn = "VPN"
        
        static let trust = "Trust"
    }
    
    // MARK: Intents
    
    public static func intentConnect(profile: ConnectionProfile) -> ConnectVPNIntent {
        let intent = ConnectVPNIntent()
        intent.context = profile.context.rawValue
        intent.profileId = profile.id
        return intent
    }
    
    public static func intentMoveTo(profile: ProviderConnectionProfile, pool: Pool) -> MoveToLocationIntent {
        let intent = MoveToLocationIntent()
        intent.providerId = profile.id
        intent.poolId = pool.id
        intent.poolName = pool.localizedId
        return intent
    }
    
    public static func intentEnable() -> EnableVPNIntent {
        return EnableVPNIntent()
    }
    
    public static func intentDisable() -> DisableVPNIntent {
        return DisableVPNIntent()
    }
    
    public static func intentTrustWiFi() -> TrustCurrentNetworkIntent {
        return TrustCurrentNetworkIntent()
    }
    
    public static func intentUntrustWiFi() -> UntrustCurrentNetworkIntent {
        return UntrustCurrentNetworkIntent()
    }
    
    public static func intentTrustCellular() -> TrustCellularNetworkIntent {
        return TrustCellularNetworkIntent()
    }
    
    public static func intentUntrustCellular() -> UntrustCellularNetworkIntent {
        return UntrustCellularNetworkIntent()
    }

    // MARK: Donations
    
    public static func donateConnection(with profile: ConnectionProfile) {
        let genericIntent: INIntent
        if let provider = profile as? ProviderConnectionProfile, let pool = provider.pool {
            genericIntent = intentMoveTo(profile: provider, pool: pool)
        } else {
            genericIntent = intentConnect(profile: profile)
        }
        
        let interaction = INInteraction(intent: genericIntent, response: nil)
        interaction.groupIdentifier = ProfileKey(profile).rawValue
        interaction.donateAndLog()
    }
    
    public static func donateEnableVPN() {
        let interaction = INInteraction(intent: intentEnable(), response: nil)
        interaction.groupIdentifier = Groups.vpn
        interaction.donateAndLog()
    }
    
    public static func donateDisableVPN() {
        let interaction = INInteraction(intent: intentDisable(), response: nil)
        interaction.groupIdentifier = Groups.vpn
        interaction.donateAndLog()
    }
    
    public static func donateTrustCurrentNetwork() {
        let interaction = INInteraction(intent: intentTrustWiFi(), response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }

    public static func donateUntrustCurrentNetwork() {
        let interaction = INInteraction(intent: intentUntrustWiFi(), response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }
    
    public static func donateTrustCellularNetwork() {
        let interaction = INInteraction(intent: intentTrustCellular(), response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }
    
    public static func donateUntrustCellularNetwork() {
        let interaction = INInteraction(intent: intentUntrustCellular(), response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }
    
    //

    public static func handleInteraction(_ interaction: INInteraction, completionHandler: ((Error?) -> Void)?) {
        handleIntent(interaction.intent, interaction: interaction, completionHandler: completionHandler)
    }

    public static func handleIntent(_ intent: INIntent, interaction: INInteraction?, completionHandler: ((Error?) -> Void)?) {
        if let custom = intent as? ConnectVPNIntent {
            handleConnectVPN(custom, interaction: interaction, completionHandler: completionHandler)
        } else if let custom = intent as? EnableVPNIntent {
            handleEnableVPN(custom, interaction: interaction, completionHandler: completionHandler)
        } else if let custom = intent as? DisableVPNIntent {
            handleDisableVPN(custom, interaction: interaction, completionHandler: completionHandler)
        } else if let custom = intent as? MoveToLocationIntent {
            handleMoveToLocation(custom, interaction: interaction, completionHandler: completionHandler)
        } else if let _ = intent as? TrustCurrentNetworkIntent {
            handleCurrentNetwork(trust: true, interaction: interaction, completionHandler: completionHandler)
        } else if let _ = intent as? UntrustCurrentNetworkIntent {
            handleCurrentNetwork(trust: false, interaction: interaction, completionHandler: completionHandler)
        } else if let _ = intent as? TrustCellularNetworkIntent {
            handleCellularNetwork(trust: true, interaction: interaction, completionHandler: completionHandler)
        } else if let _ = intent as? UntrustCellularNetworkIntent {
            handleCellularNetwork(trust: false, interaction: interaction, completionHandler: completionHandler)
        }
    }
    
    public static func handleConnectVPN(_ intent: ConnectVPNIntent, interaction: INInteraction?, completionHandler: ((Error?) -> Void)?) {
        guard let contextValue = intent.context, let context = Context(rawValue: contextValue), let id = intent.profileId else {
            if let interactionIdentifier = interaction?.identifier {
                INInteraction.delete(with: [interactionIdentifier], completion: nil)
            }
            // FIXME: error = missing data, programming error
            completionHandler?(nil)
            return
        }
        let profileKey = ProfileKey(context, id)
        log.info("Connect to profile: \(profileKey)")
        
        let service = TransientStore.shared.service
        let vpn = VPN.shared
        guard !(service.isActiveProfile(profileKey) && (vpn.status == .connected)) else {
            log.info("Profile is already active and connected")
            completionHandler?(nil)
            return
        }

        guard let profile = service.profile(withContext: context, id: id) else {
            // FIXME: error = no profile
            completionHandler?(nil)
            return
        }
        service.activateProfile(profile)
        refreshVPN(service: service, doReconnect: true, completionHandler: completionHandler)
    }

    public static func handleMoveToLocation(_ intent: MoveToLocationIntent, interaction: INInteraction?, completionHandler: ((Error?) -> Void)?) {
        guard let providerId = intent.providerId, let poolId = intent.poolId else {
            // FIXME: error = no provider/pool
            completionHandler?(nil)
            return
        }
        let service = TransientStore.shared.service
        guard let providerProfile = service.profile(withContext: .provider, id: providerId) as? ProviderConnectionProfile else {
            // FIXME: error = no provider
            completionHandler?(nil)
            return
        }
        log.info("Connect to provider location: \(providerId) @ [\(poolId)]")
        
        let vpn = VPN.shared
        guard !(service.isActiveProfile(providerProfile) && (providerProfile.poolId == poolId) && (vpn.status == .connected)) else {
            log.info("Profile is already active and connected to \(poolId)")
            completionHandler?(nil)
            return
        }

        providerProfile.poolId = poolId
        service.activateProfile(providerProfile)
        refreshVPN(service: service, doReconnect: true, completionHandler: completionHandler)
    }

    public static func handleEnableVPN(_ intent: EnableVPNIntent, interaction: INInteraction?, completionHandler: ((Error?) -> Void)?) {
        let service = TransientStore.shared.service
        log.info("Enabling VPN...")
        refreshVPN(service: service, doReconnect: true, completionHandler: completionHandler)
    }
    
    public static func handleDisableVPN(_ intent: DisableVPNIntent, interaction: INInteraction?, completionHandler: ((Error?) -> Void)?) {
        log.info("Disabling VPN...")

        let vpn = VPN.shared
        vpn.prepare {
            vpn.disconnect { (error) in
                notifyServiceUpdate()
                completionHandler?(error)
            }
        }
    }
    
    public static func handleCurrentNetwork(trust: Bool, interaction: INInteraction?, completionHandler: ((Error?) -> Void)?) {
        guard let currentWifi = Utils.currentWifiNetworkName() else {
            // FIXME: error = not connected to wifi
            completionHandler?(nil)
            return
        }
        let service = TransientStore.shared.service
        service.preferences.trustedWifis[currentWifi] = trust
        TransientStore.shared.serialize(withProfiles: false)
        
        log.info("\(trust ? "Trusted" : "Untrusted") Wi-Fi: \(currentWifi)")
        refreshVPN(service: service, doReconnect: false, completionHandler: completionHandler)
    }

    public static func handleCellularNetwork(trust: Bool, interaction: INInteraction?, completionHandler: ((Error?) -> Void)?) {
        guard Utils.hasCellularData() else {
            // FIXME: error = has no mobile data
            completionHandler?(nil)
            return
        }
        let service = TransientStore.shared.service
        service.preferences.trustsMobileNetwork = trust
        TransientStore.shared.serialize(withProfiles: false)
        
        log.info("\(trust ? "Trusted" : "Untrusted") cellular network")
        refreshVPN(service: service, doReconnect: false, completionHandler: completionHandler)
    }

    private static func refreshVPN(service: ConnectionService, doReconnect: Bool, completionHandler: ((Error?) -> Void)?) {
        let configuration: VPNConfiguration
        do {
            configuration = try service.vpnConfiguration()
        } catch let e {
            log.error("Unable to build VPN configuration: \(e)")
            notifyServiceUpdate()
            completionHandler?(e)
            return
        }
        
        let vpn = VPN.shared
        if doReconnect {
            log.info("Reconnecting VPN: \(configuration)")
            vpn.reconnect(configuration: configuration) { (error) in
                notifyServiceUpdate()
                completionHandler?(error)
            }
        } else {
            log.info("Reinstalling VPN: \(configuration)")
            vpn.install(configuration: configuration) { (error) in
                notifyServiceUpdate()
                completionHandler?(error)
            }
        }
    }
    
    //

    public static func forgetProfile(withKey profileKey: ProfileKey) {
        INInteraction.delete(with: profileKey.rawValue) { (error) in
            if let error = error {
                log.error("Unable to forget interactions: \(error)")
                return
            }
            log.debug("Removed profile \(profileKey) interactions")
        }
    }
    
    //
    
    private static func notifyServiceUpdate() {
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
