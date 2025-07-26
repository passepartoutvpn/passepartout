// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import AppLibrary
import CommonLibrary
import CommonUtils
import Foundation

extension AppContext {
    static var forUITesting: AppContext {
        let dependencies: Dependencies = .shared
        let constants: Constants = .shared
        let ctx: PartoutLoggerContext = .global

        let kvManager = KeyValueManager()
        let apiManager = APIManager(
            ctx,
            from: API.bundled,
            repository: InMemoryAPIRepository(ctx)
        )
        let iapManager = IAPManager(
            customUserLevel: .complete,
            inAppHelper: dependencies.appProductHelper(),
            receiptReader: FakeAppReceiptReader(),
            betaChecker: TestFlightChecker(),
            productsAtBuild: { _ in
                []
            }
        )
        let processor = dependencies.appProcessor(
            apiManager: apiManager,
            iapManager: iapManager,
            registry: dependencies.registry
        )
        let profileManager: ProfileManager = .forUITesting(
            withRegistry: dependencies.registry,
            processor: processor
        )
        profileManager.isRemoteImportingEnabled = true
        let tunnel = ExtendedTunnel(
            tunnel: Tunnel(ctx, strategy: FakeTunnelStrategy()) { _ in
                SharedTunnelEnvironment(profileId: nil)
            },
            processor: processor,
            interval: constants.tunnel.refreshInterval
        )
        let configManager = ConfigManager()
        let migrationManager = MigrationManager()
        let preferencesManager = PreferencesManager()
        let webReceiverManager = WebReceiverManager()

        return AppContext(
            apiManager: apiManager,
            configManager: configManager,
            distributionTarget: Dependencies.distributionTarget,
            iapManager: iapManager,
            kvManager: kvManager,
            migrationManager: migrationManager,
            preferencesManager: preferencesManager,
            profileManager: profileManager,
            registry: dependencies.registry,
            registryCoder: dependencies.registryCoder,
            sysexManager: nil,
            tunnel: tunnel,
            webReceiverManager: webReceiverManager
        )
    }
}
