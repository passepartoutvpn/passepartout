//
//  AppContext+Testing.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/28/24.
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
