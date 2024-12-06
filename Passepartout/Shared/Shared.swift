//
//  Shared.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/25/24.
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
import CommonLibrary
import CommonUtils
import CPassepartoutOpenVPNOpenSSL
import Foundation
import PassepartoutKit
import PassepartoutWireGuardGo

extension Registry {
    static let shared = Registry(
        withKnownHandlers: true,
        allImplementations: [
            OpenVPNModule.Implementation(
                prng: SecureRandom(),
                dns: SimpleDNSResolver {
                    CFDNSStrategy(hostname: $0)
                },
                importer: StandardOpenVPNParser(decrypter: OSSLTLSBox()),
                sessionBlock: { _, module in
                    guard let configuration = module.configuration else {
                        fatalError("Creating session without OpenVPN configuration?")
                    }
                    return try OpenVPNSession(
                        configuration: configuration,
                        credentials: module.credentials,
                        prng: SecureRandom(),
                        tlsFactory: {
                            OSSLTLSBox()
                        },
                        cryptoFactory: {
                            OSSLCryptoBox()
                        },
                        cachesURL: FileManager.default.temporaryDirectory
                    )
                }
            ),
            WireGuardModule.Implementation(
                keyGenerator: StandardWireGuardKeyGenerator(),
                importer: StandardWireGuardParser(),
                connectionBlock: { parameters, module in
                    try GoWireGuardConnection(parameters: parameters, module: module)
                }
            )
        ]
    )

    static var sharedProtocolCoder: KeychainNEProtocolCoder {
        KeychainNEProtocolCoder(
            tunnelBundleIdentifier: BundleConfiguration.mainString(for: .tunnelId),
            registry: .shared,
            coder: CodableProfileCoder(),
            keychain: AppleKeychain(group: BundleConfiguration.mainString(for: .keychainGroupId))
        )
    }
}

extension TunnelEnvironment where Self == AppGroupEnvironment {
    static var shared: Self {
        AppGroupEnvironment(
            appGroup: BundleConfiguration.mainString(for: .groupId),
            prefix: "PassepartoutKit."
        )
    }
}

extension InAppProcessor {

    @MainActor
    static func shared(_ iapManager: IAPManager, preview: @escaping (Profile) -> ProfilePreview) -> InAppProcessor {
        InAppProcessor(
            iapManager: iapManager,
            title: {
                Dependencies.ProfileManager.sharedTitle($0)
            },
            isIncluded: {
                Dependencies.ProfileManager.isIncluded($0, $1)
            },
            preview: preview,
            requiredFeatures: { iap, profile in
                do {
                    try iap.verify(profile)
                    return nil
                } catch AppError.ineligibleProfile(let requiredFeatures) {
                    return requiredFeatures
                } catch {
                    return nil
                }
            },
            willRebuild: { _, builder in
                builder
            },
            willInstall: { iap, profile in
                try iap.verify(profile)

                // validate provider modules
                do {
                    _ = try profile.withProviderModules()
                    return profile
                } catch {
                    pp_log(.app, .error, "Unable to inject provider modules: \(error)")
                    throw error
                }
            }
        )
    }
}

extension PreferencesManager {
    static let shared: PreferencesManager = {
        let preferencesStore = CoreDataPersistentStore(
            logger: .default,
            containerName: Constants.shared.containers.preferences,
            baseURL: BundleConfiguration.urlForGroupDocuments,
            model: AppData.cdPreferencesModel,
            cloudKitIdentifier: nil,
            author: nil
        )
        let modulePreferencesRepository = AppData.cdModulePreferencesRepositoryV3(context: preferencesStore.context)
        let providerPreferencesRepository = AppData.cdProviderPreferencesRepositoryV3(context: preferencesStore.context)
        return PreferencesManager(
            modulesRepository: modulePreferencesRepository,
            providersRepository: providerPreferencesRepository
        )
    }()
}

// MARK: - Logging

extension CoreDataPersistentStoreLogger where Self == DefaultCoreDataPersistentStoreLogger {
    static var `default`: CoreDataPersistentStoreLogger {
        DefaultCoreDataPersistentStoreLogger()
    }
}

struct DefaultCoreDataPersistentStoreLogger: CoreDataPersistentStoreLogger {
    func debug(_ msg: String) {
        pp_log(.app, .info, msg)
    }

    func warning(_ msg: String) {
        pp_log(.app, .error, msg)
    }
}
