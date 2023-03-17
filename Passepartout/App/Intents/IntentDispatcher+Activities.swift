//
//  IntentDispatcher+Activities.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/30/22.
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

@MainActor
extension IntentDispatcher {
    private enum IntentError: Error {
        case notProvider(UUID)

        case serverNotFound(UUID)

        case activeAndConnected(UUID)
    }

    typealias VPNIntentActivity = IntentActivity<VPNManager>

    static let enableVPN = VPNIntentActivity(name: Constants.Activities.enableVPN) { _, vpnManager in
        pp_log.info("Enabling VPN...")

        Task {
            do {
                try await vpnManager.connectWithActiveProfile(toServer: nil)
            } catch {
                pp_log.error("Unable to connect with active profile: \(error)")
            }
        }
    }

    static let disableVPN = VPNIntentActivity(name: Constants.Activities.disableVPN) { _, vpnManager in
        pp_log.info("Disabling VPN...")

        Task {
            await vpnManager.disable()
        }
    }

    static let connectVPN = VPNIntentActivity(name: Constants.Activities.connectVPN) { activity, vpnManager in
        pp_log.info("Connecting VPN...")

        guard let intent = activity.interaction?.intent as? ConnectVPNIntent else {
            assertionFailure("Not a ConnectVPNIntent?")
            return
        }
        guard let uuid = intent.profileId, let profileId = UUID(uuidString: uuid) else {
            assertionFailure("Profile id is not valid")
            if let interactionIdentifier = activity.interaction?.identifier {
                INInteraction.delete(with: [interactionIdentifier], completion: nil)
            }
            return
        }
        Task {
            do {
                _ = try await vpnManager.connect(with: profileId)
            } catch {
                pp_log.error("Unable to connect with profile \(profileId): \(error)")
            }
        }
    }

    static let moveToLocation = VPNIntentActivity(name: Constants.Activities.moveToLocation) { activity, vpnManager in
        pp_log.info("Moving to VPN location...")

        guard let intent = activity.interaction?.intent as? MoveToLocationIntent else {
            assertionFailure("Not a MoveToLocationIntent?")
            return
        }
        guard let uuid = intent.profileId, let profileId = UUID(uuidString: uuid) else {
            if let interactionIdentifier = activity.interaction?.identifier {
                INInteraction.delete(with: [interactionIdentifier], completion: nil)
            }
            return
        }
        guard let newServerId = intent.serverId else {
            assertionFailure("Missing serverId")
            if let interactionIdentifier = activity.interaction?.identifier {
                INInteraction.delete(with: [interactionIdentifier], completion: nil)
            }
            return
        }
        Task {
            do {
                _ = try await vpnManager.connect(with: profileId, toServer: newServerId)
            } catch {
                pp_log.error("Unable to connect with profile \(profileId): \(error)")
            }
        }
    }

    static let trustCellularNetwork = VPNIntentActivity(name: Constants.Activities.trustCellularNetwork) { _, vpnManager in
        pp_log.info("Trusting mobile network...")
        handleCellularNetwork(true, vpnManager)
    }

    static let trustCurrentNetwork = VPNIntentActivity(name: Constants.Activities.trustCurrentNetwork) { _, vpnManager in
        pp_log.info("Trusting current Wi-Fi...")
        handleCurrentNetwork(true, vpnManager)
    }

    static let untrustCellularNetwork = VPNIntentActivity(name: Constants.Activities.untrustCellularNetwork) { _, vpnManager in
        pp_log.info("Untrusting mobile network...")
        handleCellularNetwork(false, vpnManager)
    }

    static let untrustCurrentNetwork = VPNIntentActivity(name: Constants.Activities.untrustCurrentNetwork) { _, vpnManager in
        pp_log.info("Untrusting current Wi-Fi...")
        handleCurrentNetwork(false, vpnManager)
    }

    private static func handleCellularNetwork(_ trust: Bool, _ vpnManager: VPNManager) {
        Task {
            do {
                try await vpnManager.modifyActiveProfile {
                    $0.onDemand.withMobileNetwork = trust
                }
            } catch {
                pp_log.error("Unable to modify cellular trust: \(error)")
            }
        }
    }

    private static func handleCurrentNetwork(_ trust: Bool, _ vpnManager: VPNManager) {
        Task {
            guard let ssid = await Utils.currentWifiSSID() else {
                pp_log.warning("Not connected to any Wi-Fi or no permission to read location (needs 'While Using' or 'Always')")
                return
            }
            do {
                try await vpnManager.modifyActiveProfile {
                    pp_log.info("Wi-Fi SSID: \(ssid)")
                    $0.onDemand.withSSIDs[ssid] = trust
                }
            } catch {
                pp_log.error("Unable to modify Wi-Fi trust: \(error)")
            }
        }
    }
}
