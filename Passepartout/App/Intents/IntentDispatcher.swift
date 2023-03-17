//
//  IntentDispatcher.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/8/19.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import PassepartoutLibrary

class IntentDispatcher {
    private struct Groups {
        static let vpn = "VPN"

        static let trust = "Trust"
    }

    // MARK: Intents

    static func intentConnect(header: Profile.Header) -> ConnectVPNIntent {
        let intent = ConnectVPNIntent()
        intent.profileId = header.id.uuidString
        intent.profileName = header.name
        return intent
    }

    static func intentMoveTo(header: Profile.Header, providerFullName: String, server: ProviderServer) -> MoveToLocationIntent {
        let intent = MoveToLocationIntent()
        intent.profileId = header.id.uuidString
        intent.providerFullName = providerFullName
        intent.serverId = server.id
        intent.serverName = server.localizedLongDescription(withCategory: false)
        return intent
    }

    static func intentEnable() -> EnableVPNIntent {
        EnableVPNIntent()
    }

    static func intentDisable() -> DisableVPNIntent {
        DisableVPNIntent()
    }

    static func intentTrustWiFi() -> TrustCurrentNetworkIntent {
        TrustCurrentNetworkIntent()
    }

    static func intentUntrustWiFi() -> UntrustCurrentNetworkIntent {
        UntrustCurrentNetworkIntent()
    }

    static func intentTrustCellular() -> TrustCellularNetworkIntent {
        TrustCellularNetworkIntent()
    }

    static func intentUntrustCellular() -> UntrustCellularNetworkIntent {
        UntrustCellularNetworkIntent()
    }

    // MARK: Donations

    static func donateConnection(with profile: Profile, providerManager: ProviderManager) {
        let genericIntent: INIntent
        if let providerName = profile.header.providerName {
            guard let provider = providerManager.provider(withName: providerName) else {
                pp_log.warning("Intent provider not found")
                return
            }
            guard let server = profile.providerServer(providerManager) else {
                pp_log.warning("Intent server not found")
                return
            }
            genericIntent = intentMoveTo(header: profile.header, providerFullName: provider.fullName, server: server)
        } else {
            genericIntent = intentConnect(header: profile.header)
        }

        let interaction = INInteraction(intent: genericIntent, response: nil)
        interaction.groupIdentifier = profile.id.uuidString
        interaction.donateAndLog()
    }

    static func donateEnableVPN() {
        let interaction = INInteraction(intent: intentEnable(), response: nil)
        interaction.groupIdentifier = Groups.vpn
        interaction.donateAndLog()
    }

    static func donateDisableVPN() {
        let interaction = INInteraction(intent: intentDisable(), response: nil)
        interaction.groupIdentifier = Groups.vpn
        interaction.donateAndLog()
    }

    static func donateTrustCurrentNetwork() {
        let interaction = INInteraction(intent: intentTrustWiFi(), response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }

    static func donateUntrustCurrentNetwork() {
        let interaction = INInteraction(intent: intentUntrustWiFi(), response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }

    static func donateTrustCellularNetwork() {
        let interaction = INInteraction(intent: intentTrustCellular(), response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }

    static func donateUntrustCellularNetwork() {
        let interaction = INInteraction(intent: intentUntrustCellular(), response: nil)
        interaction.groupIdentifier = Groups.trust
        interaction.donateAndLog()
    }

    static func forgetProfile(withHeader header: Profile.Header) {
        INInteraction.delete(with: header.id.uuidString) { (error) in
            if let error = error {
                pp_log.warning("Unable to forget interactions: \(error)")
                return
            }
            pp_log.debug("Removed profile \(header.name) interactions")
        }
    }
}

private extension INInteraction {
    func donateAndLog() {
        donate { (error) in
            if let error = error {
                pp_log.error("Unable to donate interaction: \(error)")
            }
            pp_log.debug("Donated \(self.intent)")
        }
    }
}
