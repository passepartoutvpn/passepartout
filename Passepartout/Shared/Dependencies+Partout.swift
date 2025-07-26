// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import CommonUtils
import Foundation
import PartoutImplementations

extension Dependencies {
    var kvManager: KeyValueManager {
        Self.sharedKVStore
    }

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
    static let sharedKVStore: KeyValueManager = KeyValueManager(
        store: UserDefaultsStore(.standard),
        fallback: AppPreferenceValues()
    )

    static let sharedRegistry = Registry(
        deviceId: {
            let store = UserDefaultsStore(.standard)
            let deviceId: String
            if let existing: String = store.value(for: AppPreference.deviceId.key) {
                deviceId = existing
            } else {
                deviceId = String.random(count: Constants.shared.deviceIdLength)
                store.set(deviceId, for: AppPreference.deviceId.key)
            }
            return deviceId
        }(),
        withKnown: true,
        allImplementations: [
            OpenVPNImplementationBuilder(distributionTarget: distributionTarget).build(),
            WireGuardImplementationBuilder().build()
        ]
    )

    static let sharedProfileCoder = CodableProfileCoder()
}
