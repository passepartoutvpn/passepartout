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

import CommonLibrary
import CommonUtils
import CPassepartoutOpenVPNOpenSSL
import Foundation
import PassepartoutKit
import PassepartoutWireGuardGo

// MARK: Registry

extension Registry {
    static let shared = Registry(
        withKnownHandlers: true,
        allImplementations: [
            OpenVPNModule.Implementation(
                prng: SecureRandom(),
                dns: CFDNSResolver(),
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

// MARK: TunnelEnvironment

extension TunnelEnvironment where Self == AppGroupEnvironment {
    static var shared: Self {
        AppGroupEnvironment(
            appGroup: BundleConfiguration.mainString(for: .groupId),
            prefix: "PassepartoutKit."
        )
    }
}

// MARK: IAPManager

extension IAPManager {
    static let shared: IAPManager = {
        let iapHelpers = Configuration.IAPManager.helpers
        return IAPManager(
            customUserLevel: Configuration.Environment.userLevel,
            inAppHelper: iapHelpers.productHelper,
            receiptReader: iapHelpers.receiptReader,
            productsAtBuild: Configuration.IAPManager.productsAtBuild
        )
    }()

    static let sharedProcessor = ProfileProcessor(
        iapManager: shared,
        title: {
            Configuration.ProfileManager.sharedTitle($0)
        },
        isIncluded: {
            Configuration.ProfileManager.isIncluded($0, $1)
        },
        willSave: {
            $1
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
}

// MARK: - Configuration

enum Configuration {
    enum Environment {
    }

    enum ProfileManager {
    }

    enum IAPManager {
    }
}

// MARK: Environment

private extension Configuration.Environment {
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

// MARK: ProfileManager

extension Configuration.ProfileManager {
    static let sharedTitle: @Sendable (Profile) -> String = {
        String(format: Constants.shared.tunnel.profileTitleFormat, $0.name)
    }

#if os(tvOS)
    static let mirrorsRemoteRepository = true

    static let isIncluded: @MainActor @Sendable (CommonLibrary.IAPManager, Profile) -> Bool = {
        $1.attributes.isAvailableForTV == true
    }
#else
    static let mirrorsRemoteRepository = false

    static let isIncluded: @MainActor @Sendable (CommonLibrary.IAPManager, Profile) -> Bool = { _, _ in
        true
    }
#endif
}

// MARK: IAPManager

private extension Configuration.IAPManager {

    @MainActor
    static var helpers: (productHelper: any AppProductHelper, receiptReader: AppReceiptReader) {
        guard !Configuration.Environment.isFakeIAP else {
            let mockHelper = MockAppProductHelper()
            return (mockHelper, mockHelper.receiptReader)
        }
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
