//
//  AppContext+Mock.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/22/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import Combine
import CommonLibrary
import CommonUtils
import Foundation
import PassepartoutKit

extension AppContext {
    public static let mock: AppContext = .mock(withRegistry: Registry())

    public static func mock(withRegistry registry: Registry) -> AppContext {
        let iapManager = IAPManager(
            inAppHelper: MockAppProductHelper(),
            receiptReader: MockAppReceiptReader(),
            unrestrictedFeatures: [
                .interactiveLogin,
                .onDemand
            ],
            productsAtBuild: { _ in
                []
            }
        )
        let processor = ProfileProcessor(
            iapManager: iapManager,
            title: {
                "Passepartout.Mock: \($0.name)"
            },
            isIncluded: { _, _ in
                true
            },
            willSave: { _, builder in
                builder
            },
            willConnect: { _, profile in
                try profile.withProviderModules()
            }
        )
        let profileManager = {
            let profiles: [Profile] = (0..<20)
                .reduce(into: []) { list, _ in
                    list.append(.newMockProfile())
                }
            return ProfileManager(profiles: profiles)
        }()
        let tunnelEnvironment = InMemoryEnvironment()
        let tunnel = ExtendedTunnel(
            tunnel: Tunnel(strategy: FakeTunnelStrategy(environment: tunnelEnvironment)),
            environment: tunnelEnvironment,
            processor: processor,
            interval: Constants.shared.tunnel.refreshInterval
        )
        let providerManager = ProviderManager(
            repository: InMemoryProviderRepository()
        )
        return AppContext(
            iapManager: iapManager,
            profileManager: profileManager,
            tunnel: tunnel,
            registry: registry,
            providerManager: providerManager
        )
    }
}

// MARK: - Shortcuts

extension IAPManager {
    public static var mock: IAPManager {
        AppContext.mock.iapManager
    }
}

extension ProfileManager {
    public static var mock: ProfileManager {
        AppContext.mock.profileManager
    }
}

extension ExtendedTunnel {
    public static var mock: ExtendedTunnel {
        AppContext.mock.tunnel
    }
}

extension ProviderManager {
    public static var mock: ProviderManager {
        AppContext.mock.providerManager
    }
}
