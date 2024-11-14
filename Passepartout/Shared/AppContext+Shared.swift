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

// shared registry and environment are picked from Shared.swift

extension AppContext {
    static let shared: AppContext = {

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
        let profileManager: ProfileManager = {
            return ProfileManager(
                repository: Configuration.ProfileManager.mainProfileRepository,
                backupRepository: Configuration.ProfileManager.backupProfileRepository,
                remoteRepositoryBlock: remoteRepositoryBlock,
                mirrorsRemoteRepository: Configuration.ProfileManager.mirrorsRemoteRepository,
                processor: IAPManager.sharedProcessor
            )
        }()

        // MARK: ExtendedTunnel

        let tunnel = ExtendedTunnel(
            tunnel: Tunnel(strategy: Configuration.ExtendedTunnel.strategy),
            environment: .shared,
            processor: IAPManager.sharedProcessor,
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
            let repository = AppData.cdProviderRepositoryV3(
                context: store.context,
                backgroundContext: store.backgroundContext
            )
            return ProviderManager(repository: repository)
        }()

        // MARK: MigrationManager

        let profileStrategy = ProfileV2MigrationStrategy(
            coreDataLogger: .default,
            profilesContainerName: Constants.shared.containers.legacyV2,
            cloudKitIdentifier: BundleConfiguration.mainString(for: .legacyV2CloudKitId)
        )
#if DEBUG
        let migrationManager = MigrationManager(profileStrategy: profileStrategy, simulation: .init(
            maxMigrationTime: 3.0,
            randomFailures: true
        ))
#else
        let migrationManager = MigrationManager(profileStrategy: profileStrategy)
#endif

        return AppContext(
            iapManager: .shared,
            migrationManager: migrationManager,
            profileManager: profileManager,
            providerManager: providerManager,
            registry: .shared,
            tunnel: tunnel
        )
    }()
}

// MARK: - Configuration

private extension Configuration {
    enum ExtendedTunnel {
    }
}

// MARK: Simulator

#if targetEnvironment(simulator)

@MainActor
private extension Configuration.ProfileManager {
    static var mainProfileRepository: ProfileRepository {
        coreDataProfileRepository
    }

    static var backupProfileRepository: ProfileRepository? {
        nil
    }
}

private extension Configuration.ExtendedTunnel {
    static var strategy: TunnelObservableStrategy {
        FakeTunnelStrategy(environment: .shared, dataCountInterval: 1000)
    }
}

#else

// MARK: Device

@MainActor
private extension Configuration.ProfileManager {
    static var mainProfileRepository: ProfileRepository {
        neProfileRepository
    }

    static var backupProfileRepository: ProfileRepository? {
        coreDataProfileRepository
    }
}

@MainActor
private extension Configuration.ExtendedTunnel {
    static var strategy: TunnelObservableStrategy {
        Configuration.ProfileManager.neStrategy
    }
}

#endif

// MARK: Common

@MainActor
private extension Configuration.ProfileManager {
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

    static let coreDataProfileRepository: ProfileRepository = {
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
    }()
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
