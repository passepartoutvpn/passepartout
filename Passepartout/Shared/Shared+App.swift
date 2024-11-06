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
import AppDataProviders
import CommonLibrary
import CommonUtils
import Foundation
import PassepartoutKit
import UILibrary

extension AppContext {
    static let shared: AppContext = {
        let tunnelEnvironment: TunnelEnvironment = .shared
        let registry: Registry = .shared

        let iapHelpers = Configuration.IAPManager.helpers
        let iapManager = IAPManager(
            customUserLevel: Configuration.Environment.userLevel,
            inAppHelper: iapHelpers.0,
            receiptReader: iapHelpers.1,
            // FIXME: #662, omit unrestrictedFeatures on release!
            unrestrictedFeatures: [.interactiveLogin],
            productsAtBuild: Configuration.IAPManager.productsAtBuild
        )
        let processor = ProfileProcessor(
            iapManager: iapManager,
            title: {
                Configuration.ProfileManager.sharedTitle($0)
            },
            isIncluded: { _, profile in
                Configuration.ProfileManager.isProfileIncluded(profile)
            },
            willSave: { iap, builder in
                var copy = builder
                var attributes = copy.attributes

                // preprocess TV profiles
                if attributes.isAvailableForTV == true {

                    // ineligible, set expiration date unless already set
                    if !iap.isEligible(for: .appleTV),
                       attributes.expirationDate == nil || attributes.isExpired {
                        let expirationDate = Constants.shared.tunnel.newTVExpirationDate()
                        pp_log(.app, .notice, "Ineligible, apply expiration date: \(expirationDate)")
                        attributes.expirationDate = expirationDate
                    } else {
                        attributes.expirationDate = nil
                    }
                }

                copy.attributes = attributes
                return copy
            },
            willConnect: { iap, profile in
                var builder = profile.builder()

                // ineligible, suppress on-demand rules
                if !iap.isEligible(for: .onDemand) {
                    pp_log(.app, .notice, "Ineligible, suppress on-demand rules")

                    if let onDemandModuleIndex = builder.modules.firstIndex(where: { $0 is OnDemandModule }),
                       let onDemandModule = builder.modules[onDemandModuleIndex] as? OnDemandModule {

                        var onDemandBuilder = onDemandModule.builder()
                        onDemandBuilder.policy = .any
                        builder.modules[onDemandModuleIndex] = onDemandBuilder.tryBuild()
                    }
                }

                // validate provider modules
                let profile = try builder.tryBuild()
                do {
                    _ = try profile.withProviderModules()
                    return profile
                } catch {
                    pp_log(.app, .error, "Unable to inject provider modules: \(error)")
                    throw error
                }
            }
        )
        let profileManager: ProfileManager = {
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
            return ProfileManager(
                repository: Configuration.ProfileManager.mainProfileRepository,
                backupRepository: Configuration.ProfileManager.backupProfileRepository,
                remoteRepository: remoteRepository,
                deletingRemotely: Configuration.ProfileManager.deletingRemotely,
                processor: processor
            )
        }()
        let tunnel = ExtendedTunnel(
            tunnel: Tunnel(strategy: Configuration.ExtendedTunnel.strategy),
            environment: tunnelEnvironment,
            processor: processor,
            interval: Constants.shared.tunnel.refreshInterval
        )
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
        return AppContext(
            iapManager: iapManager,
            profileManager: profileManager,
            tunnel: tunnel,
            registry: registry,
            providerManager: providerManager
        )
    }()
}

// MARK: - Configuration

private enum Configuration {
    enum Environment {
        static var isFakeIAP: Bool {
            ProcessInfo.processInfo.environment["PP_FAKE_IAP"] == "1"
        }

        static var userLevel: AppUserLevel? {
            if let envString = ProcessInfo.processInfo.environment["PP_USER_LEVEL"],
               let envValue = Int(envString),
               let testAppType = AppUserLevel(rawValue: envValue) {

                return testAppType
            }
            if let infoValue = BundleConfiguration.mainIntegerIfPresent(for: .userLevel),
               let testAppType = AppUserLevel(rawValue: infoValue) {

                return testAppType
            }
            return nil
        }
    }
}

extension Configuration {
    enum IAPManager {

        @MainActor
        static var helpers: (any AppProductHelper, AppReceiptReader) {
            if Environment.isFakeIAP {
                let mockHelper = MockAppProductHelper()
                return (mockHelper, mockHelper.receiptReader)
            } else {
                let productHelper = StoreKitHelper(
                    products: AppProduct.all,
                    inAppIdentifier: {
                        let prefix = BundleConfiguration.mainString(for: .iapBundlePrefix)
                        return "\(prefix).\($0.rawValue)"
                    }
                )
                let receiptReader = FallbackReceiptReader(
                    reader: StoreKitReceiptReader(),
                    localReader: {
                        KvittoReceiptReader(url: $0)
                    }
                )
                return (productHelper, receiptReader)
            }
        }

        static let productsAtBuild: BuildProducts<AppProduct> = {
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
}

extension Configuration {
    enum ProfileManager {
        static let sharedTitle: @Sendable (Profile) -> String = {
            String(format: Constants.shared.tunnel.profileTitleFormat, $0.name)
        }

#if os(tvOS)
        static let deletingRemotely = true

        static let isProfileIncluded: @Sendable (Profile) -> Bool = {
            $0.attributes.isAvailableForTV == true
        }
#else
        static let deletingRemotely = false

        static let isProfileIncluded: @Sendable (Profile) -> Bool = { _ in
            true
        }
#endif
    }
}

#if targetEnvironment(simulator)

extension Configuration {
    enum ExtendedTunnel {
        static var strategy: TunnelObservableStrategy {
            FakeTunnelStrategy(environment: .shared, dataCountInterval: 1000)
        }
    }
}

@MainActor
extension Configuration.ProfileManager {
    static var mainProfileRepository: ProfileRepository {
        coreDataProfileRepository
    }

    static var backupProfileRepository: ProfileRepository? {
        nil
    }
}

#else

extension Configuration {

    @MainActor
    enum ExtendedTunnel {
        static var strategy: TunnelObservableStrategy {
            ProfileManager.neStrategy
        }
    }
}

@MainActor
extension Configuration.ProfileManager {
    static var mainProfileRepository: ProfileRepository {
        neProfileRepository
    }

    static var backupProfileRepository: ProfileRepository? {
        coreDataProfileRepository
    }
}

#endif

@MainActor
extension Configuration.ProfileManager {
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
