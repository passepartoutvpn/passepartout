//
//  AppContext+Shared.swift
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
import AppDataPreferences
import AppDataProfiles
import AppDataProviders
import CommonLibrary
import CommonUtils
import CoreData
import Foundation
import LegacyV2
import PassepartoutKit
import UIAccessibility
import UILibrary

extension AppContext {
    static let shared: AppContext = {
        let dependencies: Dependencies = .shared

        guard let cdRemoteModel = NSManagedObjectModel.mergedModel(from: [
            AppData.profilesBundle,
            AppData.preferencesBundle
        ]) else {
            fatalError("Unable to load remote model")
        }
        guard let cdLocalModel = NSManagedObjectModel.mergedModel(from: [
            AppData.providersBundle
        ]) else {
            fatalError("Unable to load local model")
        }

        let iapManager = IAPManager(
            customUserLevel: dependencies.customUserLevel,
            inAppHelper: dependencies.simulatedAppProductHelper(),
            receiptReader: dependencies.simulatedAppReceiptReader(),
            betaChecker: dependencies.betaChecker(),
            productsAtBuild: dependencies.productsAtBuild()
        )

        let processor = dependencies.appProcessor(with: iapManager)
        let tunnelEnvironment = dependencies.tunnelEnvironment()

#if targetEnvironment(simulator)
        let tunnelStrategy = FakeTunnelStrategy(environment: tunnelEnvironment, dataCountInterval: 1000)
        let mainProfileRepository = dependencies.coreDataProfileRepository(
            model: cdRemoteModel,
            observingResults: true
        )
#else
        let tunnelStrategy = NETunnelStrategy(
            bundleIdentifier: BundleConfiguration.mainString(for: .tunnelId),
            coder: dependencies.neProtocolCoder(),
            environment: tunnelEnvironment
        )
        let mainProfileRepository = NEProfileRepository(repository: tunnelStrategy) {
            dependencies.profileTitle($0)
        }
#endif

        let profileManager: ProfileManager = {
            let remoteRepositoryBlock: (Bool) -> ProfileRepository = {
                let remoteStore = CoreDataPersistentStore(
                    logger: dependencies.coreDataLogger(),
                    containerName: Constants.shared.containers.remote,
                    model: cdRemoteModel,
                    cloudKitIdentifier: $0 ? BundleConfiguration.mainString(for: .cloudKitId) : nil,
                    author: nil
                )
                return AppData.cdProfileRepositoryV3(
                    registry: dependencies.registry,
                    coder: CodableProfileCoder(),
                    context: remoteStore.context,
                    observingResults: true,
                    onResultError: {
                        pp_log(.App.profiles, .error, "Unable to decode remote profile: \($0)")
                        return .ignore
                    }
                )
            }
            return ProfileManager(
                repository: mainProfileRepository,
                backupRepository: dependencies.backupProfileRepository(
                    model: cdRemoteModel
                ),
                remoteRepositoryBlock: remoteRepositoryBlock,
                mirrorsRemoteRepository: dependencies.mirrorsRemoteRepository,
                processor: processor
            )
        }()

        let tunnel = ExtendedTunnel(
            tunnel: Tunnel(strategy: tunnelStrategy),
            environment: tunnelEnvironment,
            processor: processor,
            interval: Constants.shared.tunnel.refreshInterval
        )

        let providerManager: ProviderManager = {
            let store = CoreDataPersistentStore(
                logger: dependencies.coreDataLogger(),
                containerName: Constants.shared.containers.local,
                model: cdLocalModel,
                cloudKitIdentifier: nil,
                author: nil
            )
            let repository = AppData.cdProviderRepositoryV3(context: store.backgroundContext())
            return ProviderManager(repository: repository)
        }()

        let migrationManager: MigrationManager = {
            let profileStrategy = ProfileV2MigrationStrategy(
                coreDataLogger: dependencies.coreDataLogger(),
                profilesContainer: .init(
                    Constants.shared.containers.legacyV2,
                    BundleConfiguration.mainString(for: .legacyV2CloudKitId)
                ),
                tvProfilesContainer: .init(
                    Constants.shared.containers.legacyV2TV,
                    BundleConfiguration.mainString(for: .legacyV2TVCloudKitId)
                )
            )
            let migrationSimulation: MigrationManager.Simulation?
            if AppCommandLine.contains(.fakeMigration) {
                migrationSimulation = MigrationManager.Simulation(
                    fakeProfiles: true,
                    maxMigrationTime: 3.0,
                    randomFailures: true
                )
            } else {
                migrationSimulation = nil
            }
            return MigrationManager(profileStrategy: profileStrategy, simulation: migrationSimulation)
        }()

        let preferencesManager: PreferencesManager = {
            let preferencesStore = CoreDataPersistentStore(
                logger: dependencies.coreDataLogger(),
                containerName: Constants.shared.containers.remote,
                model: cdRemoteModel,
                cloudKitIdentifier: BundleConfiguration.mainString(for: .cloudKitId),
                author: nil
            )
            return PreferencesManager(
                modulesFactory: {
                    try AppData.cdModulePreferencesRepositoryV3(
                        context: preferencesStore.context,
                        moduleId: $0
                    )
                },
                providersFactory: {
                    try AppData.cdProviderPreferencesRepositoryV3(
                        context: preferencesStore.context,
                        providerId: $0
                    )
                }
            )
        }()

        return AppContext(
            iapManager: iapManager,
            migrationManager: migrationManager,
            profileManager: profileManager,
            providerManager: providerManager,
            preferencesManager: preferencesManager,
            registry: dependencies.registry,
            tunnel: tunnel,
            tunnelReceiptURL: BundleConfiguration.urlForBetaReceipt
        )
    }()
}

// MARK: - Dependencies

private extension Dependencies {
    var customUserLevel: AppUserLevel? {
        guard let userLevelString = BundleConfiguration.mainIntegerIfPresent(for: .userLevel),
              let userLevel = AppUserLevel(rawValue: userLevelString) else {
            return nil
        }
        return userLevel
    }

    func simulatedAppProductHelper() -> any AppProductHelper {
        if AppCommandLine.contains(.fakeIAP) {
            return FakeAppProductHelper()
        }
        return appProductHelper()
    }

    func simulatedAppReceiptReader() -> AppReceiptReader {
        if AppCommandLine.contains(.fakeIAP) {
            guard let mockHelper = simulatedAppProductHelper() as? FakeAppProductHelper else {
                fatalError("When .isFakeIAP, simulatedInAppHelper is expected to be MockAppProductHelper")
            }
            return mockHelper.receiptReader
        }
        return FallbackReceiptReader(
            main: StoreKitReceiptReader(),
            beta: betaReceiptURL.map {
                KvittoReceiptReader(url: $0)
            }
        )
    }

    var betaReceiptURL: URL? {
        Bundle.main.appStoreProductionReceiptURL
    }

    var mirrorsRemoteRepository: Bool {
#if os(tvOS)
        true
#else
        false
#endif
    }

    func backupProfileRepository(model: NSManagedObjectModel) -> ProfileRepository? {
#if targetEnvironment(simulator)
        nil
#else
        coreDataProfileRepository(model: model, observingResults: false)
#endif
    }

    func coreDataProfileRepository(model: NSManagedObjectModel, observingResults: Bool) -> ProfileRepository {
        let store = CoreDataPersistentStore(
            logger: coreDataLogger(),
            containerName: Constants.shared.containers.backup,
            model: model,
            cloudKitIdentifier: nil,
            author: nil
        )
        return AppData.cdProfileRepositoryV3(
            registry: registry,
            coder: CodableProfileCoder(),
            context: store.context,
            observingResults: observingResults,
            onResultError: {
                pp_log(.App.profiles, .error, "Unable to decode local profile: \($0)")
                return .ignore
            }
        )
    }
}
