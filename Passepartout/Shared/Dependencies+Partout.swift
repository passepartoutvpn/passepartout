//
//  Dependencies+Partout.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/2/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import Foundation
import PartoutOpenVPN
import PartoutWireGuard

extension Dependencies {
    var registry: Registry {
        Self.sharedRegistry
    }

    var registryCoder: RegistryCoder {
        RegistryCoder(
            registry: Self.sharedRegistry,
            coder: Self.sharedProfileCoder
        )
    }

    func neProtocolCoder(_ ctx: PartoutLoggerContext) -> NEProtocolCoder {
        if Self.distributionTarget.supportsAppGroups {
            return KeychainNEProtocolCoder(
                ctx,
                tunnelBundleIdentifier: BundleConfiguration.mainString(for: .tunnelId),
                registry: registry,
                coder: Self.sharedProfileCoder,
                keychain: AppleKeychain(ctx, group: BundleConfiguration.mainString(for: .keychainGroupId))
            )
        } else {
            return ProviderNEProtocolCoder(
                ctx,
                tunnelBundleIdentifier: BundleConfiguration.mainString(for: .tunnelId),
                registry: registry,
                coder: Self.sharedProfileCoder
            )
        }
    }

    nonisolated func appTunnelEnvironment(strategy: TunnelStrategy, profileId: Profile.ID) -> TunnelEnvironmentReader {
        if Self.distributionTarget.supportsAppGroups {
            return tunnelEnvironment(profileId: profileId)
        } else {
            guard let neStrategy = strategy as? NETunnelStrategy else {
                fatalError("NETunnelEnvironment requires NETunnelStrategy")
            }
            return NETunnelEnvironment(strategy: neStrategy, profileId: profileId)
        }
    }

    nonisolated func tunnelEnvironment(profileId: Profile.ID) -> TunnelEnvironment {
        let appGroup = BundleConfiguration.mainString(for: .groupId)
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            fatalError("No access to App Group: \(appGroup)")
        }
        return UserDefaultsEnvironment(profileId: profileId, defaults: defaults)
    }
}

private extension Dependencies {
    static let sharedRegistry = Registry(
        withKnown: true,
        allImplementations: [
            OpenVPNModule.Implementation(
                importer: StandardOpenVPNParser(),
                connectionBlock: {
                    let ctx = PartoutLoggerContext($0.controller.profile.id)
                    var options = OpenVPN.ConnectionOptions()
                    options.writeTimeout = TimeInterval($0.options.linkWriteTimeout) / 1000.0
                    options.minDataCountInterval = TimeInterval($0.options.minDataCountInterval) / 1000.0
                    return try await OpenVPNConnection(
                        ctx,
                        parameters: $0,
                        module: $1,
                        prng: AppleRandom(),
                        dns: SimpleDNSResolver {
                            if distributionTarget.usesExperimentalPOSIXResolver {
                                return POSIXDNSStrategy(hostname: $0)
                            } else {
                                return CFDNSStrategy(hostname: $0)
                            }
                        },
                        options: options,
                        // TODO: #218, this directory must be per-profile
                        cachesURL: FileManager.default.temporaryDirectory
                    )
                }
            ),
            WireGuardModule.Implementation(
                keyGenerator: StandardWireGuardKeyGenerator(),
                importer: StandardWireGuardParser(),
                validator: StandardWireGuardParser(),
                connectionBlock: {
                    let ctx = PartoutLoggerContext($0.controller.profile.id)
                    return try WireGuardConnection(
                        ctx,
                        parameters: $0,
                        module: $1
                    )
                }
            )
        ]
    )

    static let sharedProfileCoder = CodableProfileCoder()
}
