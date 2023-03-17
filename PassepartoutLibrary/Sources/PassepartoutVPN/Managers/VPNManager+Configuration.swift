//
//  VPNManager+Configuration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/12/22.
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
import PassepartoutCore
import PassepartoutUtils

extension VPNManager {
    var vpnPreferences: VPNPreferences {
        DefaultVPNPreferences(
            tunnelLogPath: tunnelLogPath,
            tunnelLogFormat: tunnelLogFormat,
            masksPrivateData: masksPrivateData
        )
    }

    func vpnConfigurationWithCurrentProfile() -> VPNConfiguration? {
        do {
            guard profileManager.isCurrentProfileActive() else {
                pp_log.info("Skipping VPN configuration, current profile is not active")
                return nil
            }
            return try vpnConfiguration(withProfile: profileManager.currentProfile.value)
        } catch {
            return nil
        }
    }

    func vpnConfiguration(withProfile profile: Profile) throws -> VPNConfiguration {
        do {
            if profile.requiresCredentials {
                guard !profile.account.isEmpty else {
                    throw PassepartoutError.missingAccount
                }
            }

            // specific provider customizations
            var newPassword: String?
            if let providerName = profile.providerName {
                switch providerName {
                case .mullvad:
                    newPassword = "m"

                default:
                    break
                }
            }

            // IMPORTANT: must commit password to keychain (tunnel needs a password reference)
            profileManager.savePassword(forProfile: profile, newPassword: newPassword)

            let parameters = VPNConfigurationParameters(
                profile,
                appGroup: appGroup,
                preferences: vpnPreferences,
                passwordReference: profileManager.passwordReference(forProfile: profile),
                withNetworkSettings: isNetworkSettingsSupported(),
                withCustomRules: isOnDemandRulesSupported()
            )

            switch profile.currentVPNProtocol {
            case .openVPN:
                let settings: Profile.OpenVPNSettings
                if profile.isProvider {
                    settings = try profile.providerOpenVPNSettings(withManager: providerManager)
                } else {
                    guard let hostSettings = profile.hostOpenVPNSettings else {
                        fatalError("Profile currentVPNProtocol is OpenVPN, but host has no OpenVPN settings")
                    }
                    settings = hostSettings
                }
                return try settings.vpnConfiguration(parameters)

            case .wireGuard:
                let settings: Profile.WireGuardSettings
                if profile.isProvider {
                    settings = try profile.providerWireGuardSettings(withManager: providerManager)
                } else {
                    guard let hostSettings = profile.hostWireGuardSettings else {
                        fatalError("Profile currentVPNProtocol is WireGuard, but host has no WireGuard settings")
                    }
                    settings = hostSettings
                }
                return try settings.vpnConfiguration(parameters)
            }
        } catch {
            pp_log.error("Unable to build VPNConfiguration: \(error)")

            // UI is certainly interested in configuration errors
            configurationError.send((profile, error))

            throw error
        }
    }
}
