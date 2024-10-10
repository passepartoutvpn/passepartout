//
//  Shared+App.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/24/24.
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

import AppData
import AppDataProfiles
import AppLibrary
import AppUI
import CommonLibrary
import Foundation
import PassepartoutKit
import UtilsLibrary

extension AppContext {
    static let shared = AppContext(
        iapManager: .shared,
        profileManager: .shared,
        profileProcessor: .shared,
        tunnel: .shared,
        tunnelEnvironment: .shared,
        registry: .shared,
        providerFactory: .shared,
        constants: .shared
    )
}

// MARK: -

extension ProfileManager {
    static let shared: ProfileManager = {
        let repository = localProfileRepository

        let remoteStore = CoreDataPersistentStore(
            logger: .default,
            containerName: Constants.shared.containers.remote,
            model: AppData.cdProfilesModel,
            cloudKitIdentifier: BundleConfiguration.mainString(for: .cloudKitId),
            author: nil
        )
        let remoteRepository = AppData.cdProfileRepositoryV3(
            registry: .shared,
            coder: CodableProfileCoder(),
            context: remoteStore.context,
            observingResults: true
        ) { error in
            pp_log(.app, .error, "Unable to decode remote result: \(error)")
            return .ignore
        }

        return ProfileManager(repository: repository, remoteRepository: remoteRepository)
    }()
}

// MARK: -

extension IAPManager {
    static let shared = IAPManager(
        customUserLevel: customUserLevel,
        receiptReader: KvittoReceiptReader(),
        // FIXME: #662, omit unrestrictedFeatures on release!
        unrestrictedFeatures: [.interactiveLogin, .sharing],
        productsAtBuild: productsAtBuild
    )

    private static var customUserLevel: AppUserLevel? {
        if let envString = ProcessInfo.processInfo.environment["CUSTOM_USER_LEVEL"],
           let envValue = Int(envString),
           let testAppType = AppUserLevel(rawValue: envValue) {

            return testAppType
        }
        if let infoValue = BundleConfiguration.mainIntegerIfPresent(for: .customUserLevel),
           let testAppType = AppUserLevel(rawValue: infoValue) {

            return testAppType
        }
        return nil
    }

    private static let productsAtBuild: BuildProducts<AppProduct> = {
#if os(iOS)
        if $0 <= 2016 {
            return [.Full.iOS]
        } else if $0 <= 3000 {
            return [.Features.networkSettings]
        }
        return []
#elseif os(macOS)
        if $0 <= 3000 {
            return [.Features.networkSettings]
        }
        return []
#else
        return []
#endif
    }
}

extension ProfileProcessor {
    static let shared = ProfileProcessor { profile in
        var builder = profile.builder()

        // suppress on-demand rules if not eligible
        if !IAPManager.shared.isEligible(for: .onDemand) {
            pp_log(.app, .notice, "Suppress on-demand rules, not eligible")

            if let onDemandModuleIndex = builder.modules.firstIndex(where: { $0 is OnDemandModule }),
                let onDemandModule = builder.modules[onDemandModuleIndex] as? OnDemandModule {

                var onDemandBuilder = onDemandModule.builder()
                onDemandBuilder.policy = .any
                builder.modules[onDemandModuleIndex] = onDemandBuilder.tryBuild()
            }
        }

        let processed = try builder.tryBuild()
        do {
            return try processed.withProviderModules()
        } catch {
            // FIXME: #703, alert unable to build provider server
            pp_log(.app, .error, "Unable to inject provider modules: \(error)")
            return processed
        }
    }
}

// MARK: -

#if targetEnvironment(simulator)

extension Tunnel {
    static let shared = Tunnel(
        strategy: FakeTunnelStrategy(environment: .shared, dataCountInterval: 1000)
    )
}

private var localProfileRepository: any ProfileRepository {
    let store = CoreDataPersistentStore(
        logger: .default,
        containerName: Constants.shared.containers.local,
        model: AppData.cdProfilesModel,
        cloudKitIdentifier: nil,
        author: nil
    )
    return AppData.cdProfileRepositoryV3(
        registry: .shared,
        coder: CodableProfileCoder(),
        context: store.context,
        observingResults: false
    ) { error in
        pp_log(.app, .error, "Unable to decode local result: \(error)")
        return .ignore
    }
}

#else

extension Tunnel {
    static let shared = Tunnel(
        strategy: NETunnelStrategy(repository: neRepository)
    )
}

private var localProfileRepository: any ProfileRepository {
    NEProfileRepository(repository: neRepository)
}

private var neRepository: NETunnelManagerRepository {
    NETunnelManagerRepository(
        bundleIdentifier: BundleConfiguration.mainString(for: .tunnelId),
        coder: Registry.sharedProtocolCoder,
        environment: .shared
    )
}

#endif

// MARK: -

// FIXME: #705, store providers to Core Data
extension ProviderFactory {
    static let shared = ProviderFactory(
        providerManager: ProviderManager(repository: InMemoryProviderRepository()),
        vpnProviderManager: VPNProviderManager(repository: InMemoryVPNProviderRepository())
    )
}

// MARK: -

extension CoreDataPersistentStoreLogger where Self == DefaultCoreDataPersistentStoreLogger {
    static var `default`: CoreDataPersistentStoreLogger {
        DefaultCoreDataPersistentStoreLogger()
    }
}

private struct DefaultCoreDataPersistentStoreLogger: CoreDataPersistentStoreLogger {
    func debug(_ msg: String) {
        pp_log(.app, .info, msg)
    }

    func warning(_ msg: String) {
        pp_log(.app, .error, msg)
    }
}
