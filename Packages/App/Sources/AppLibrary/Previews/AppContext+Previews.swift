//
//  AppContext+Previews.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/22/24.
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
import CommonUtils
import Foundation

extension AppContext {
    public static let forPreviews: AppContext = {
        let constants: Constants = .shared

        let kvManager = KeyValueManager()
        let iapManager = IAPManager(
            customUserLevel: .complete,
            inAppHelper: FakeAppProductHelper(),
            receiptReader: FakeAppReceiptReader(),
            betaChecker: TestFlightChecker(),
            productsAtBuild: { _ in
                []
            }
        )
        let processor = MockAppProcessor(iapManager: iapManager)
        let profileManager = {
            let profiles: [Profile] = (0..<20)
                .reduce(into: []) { list, _ in
                    list.append(.newMockProfile())
                }
            return ProfileManager(profiles: profiles)
        }()
        let tunnel = ExtendedTunnel(
            tunnel: Tunnel(.global, strategy: FakeTunnelStrategy()) { _ in
                SharedTunnelEnvironment(profileId: nil)
            },
            processor: processor,
            interval: constants.tunnel.refreshInterval
        )
        let apiManager = APIManager(
            .global,
            from: API.bundled,
            repository: InMemoryAPIRepository(.global)
        )
        let configManager = ConfigManager()
        let migrationManager = MigrationManager()
        let preferencesManager = PreferencesManager()
        let registry = Registry()
        let registryCoder = RegistryCoder(registry: registry, coder: CodableProfileCoder())

        let dummyReceiver = DummyWebReceiver(url: URL(string: "http://127.0.0.1:9000")!)
        let webReceiverManager = WebReceiverManager(webReceiver: dummyReceiver, passcodeGenerator: { "123456" })

        let distributionTarget: DistributionTarget = .appStore

        return AppContext(
            apiManager: apiManager,
            configManager: configManager,
            distributionTarget: distributionTarget,
            iapManager: iapManager,
            kvManager: kvManager,
            migrationManager: migrationManager,
            preferencesManager: preferencesManager,
            profileManager: profileManager,
            registry: registry,
            registryCoder: registryCoder,
            sysexManager: nil,
            tunnel: tunnel,
            webReceiverManager: webReceiverManager
        )
    }()
}

// MARK: - Shortcuts

extension IAPManager {
    public static var forPreviews: IAPManager {
        AppContext.forPreviews.iapManager
    }
}

extension ProfileManager {
    public static var forPreviews: ProfileManager {
        AppContext.forPreviews.profileManager
    }
}

extension ExtendedTunnel {
    public static var forPreviews: ExtendedTunnel {
        AppContext.forPreviews.tunnel
    }
}

extension APIManager {
    public static var forPreviews: APIManager {
        AppContext.forPreviews.apiManager
    }
}

extension WebReceiverManager {
    public static var forPreviews: WebReceiverManager {
        AppContext.forPreviews.webReceiverManager
    }
}
