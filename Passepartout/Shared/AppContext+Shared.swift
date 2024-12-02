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
import AppDataProfiles
import AppDataProviders
import CommonLibrary
import CommonUtils
import Foundation
import LegacyV2
import PassepartoutKit
import UILibrary
import UITesting

// shared registry and environment are picked from Shared.swift

extension AppContext {
    static let shared: AppContext = {
        let iapManager: IAPManager = .sharedForApp
        let processor = InAppProcessor.shared(iapManager) {
            $0.localizedPreview
        }

        // MARK: ProfileManager

        let remoteRepositoryBlock: (Bool) -> ProfileRepository = {
            let remoteStore = CoreDataPersistentStore(
                logger: .default,
                containerName: Constants.shared.containers.remote,
                model: AppData.cdProfilesModel,
                cloudKitIdentifier: $0 ? BundleConfiguration.mainString(for: .cloudKitId) : nil,
                author: nil
            )
            return AppData.cdProfileRepositoryV3(
                registry: .shared,
                coder: CodableProfileCoder(),
                context: remoteStore.context,
                observingResults: true
            ) { error in
                pp_log(.app, .error, "Unable to decode remote result: \(error)")
                return .ignore
            }
        }
        let profileManager = ProfileManager(
            repository: Dependencies.ProfileManager.mainProfileRepository,
            backupRepository: Dependencies.ProfileManager.backupProfileRepository,
            remoteRepositoryBlock: remoteRepositoryBlock,
            mirrorsRemoteRepository: Dependencies.ProfileManager.mirrorsRemoteRepository,
            processor: processor
        )

        // MARK: ExtendedTunnel

        let tunnel = ExtendedTunnel(
            tunnel: Tunnel(strategy: Dependencies.ExtendedTunnel.strategy),
            environment: .shared,
            processor: processor,
            interval: Constants.shared.tunnel.refreshInterval
        )

        // MARK: ProviderManager

        let providerManager: ProviderManager = {
            let store = CoreDataPersistentStore(
                logger: .default,
                containerName: Constants.shared.containers.providers,
                model: AppData.cdProvidersModel,
                cloudKitIdentifier: nil,
                author: nil
            )
            let repository = AppData.cdProviderRepositoryV3(context: store.backgroundContext)
            return ProviderManager(repository: repository)
        }()

        // MARK: MigrationManager

        let profileStrategy = ProfileV2MigrationStrategy(
            coreDataLogger: .default,
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
        let migrationManager = MigrationManager(profileStrategy: profileStrategy, simulation: migrationSimulation)

        return AppContext(
            iapManager: iapManager,
            migrationManager: migrationManager,
            profileManager: profileManager,
            providerManager: providerManager,
            registry: .shared,
            tunnel: tunnel,
            tunnelReceiptURL: BundleConfiguration.urlForBetaReceipt
        )
    }()
}

// MARK: - Dependencies

// MARK: Simulator

#if targetEnvironment(simulator)

private extension Dependencies.ExtendedTunnel {
    static var strategy: TunnelObservableStrategy {
        FakeTunnelStrategy(environment: .shared, dataCountInterval: 1000)
    }
}

@MainActor
private extension Dependencies.ProfileManager {
    static var mainProfileRepository: ProfileRepository {
        coreDataProfileRepository(observingResults: true)
    }

    static var backupProfileRepository: ProfileRepository? {
        nil
    }
}

#else

// MARK: Device

@MainActor
private extension Dependencies.ExtendedTunnel {
    static var strategy: TunnelObservableStrategy {
        Dependencies.ProfileManager.neStrategy
    }
}

@MainActor
private extension Dependencies.ProfileManager {
    static var mainProfileRepository: ProfileRepository {
        neProfileRepository
    }

    static var backupProfileRepository: ProfileRepository? {
        coreDataProfileRepository(observingResults: false)
    }
}

#endif

// MARK: Common

@MainActor
private extension Dependencies.ProfileManager {
    static let neProfileRepository: ProfileRepository = {
        NEProfileRepository(repository: neStrategy) {
            sharedTitle($0)
        }
    }()

    static let neStrategy: NETunnelStrategy = {
        NETunnelStrategy(
            bundleIdentifier: BundleConfiguration.mainString(for: .tunnelId),
            coder: Registry.sharedProtocolCoder,
            environment: .shared
        )
    }()

    static func coreDataProfileRepository(observingResults: Bool) -> ProfileRepository {
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
            observingResults: observingResults
        ) { error in
            pp_log(.app, .error, "Unable to decode local result: \(error)")
            return .ignore
        }
    }
}

// MARK: - Logging

private extension CoreDataPersistentStoreLogger where Self == DefaultCoreDataPersistentStoreLogger {
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
