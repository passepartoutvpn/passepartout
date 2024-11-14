//
//  Shared+App.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/14/24.
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
import Foundation
import PassepartoutKit

extension IAPManager {
    static let sharedForApp = IAPManager(
        customUserLevel: Configuration.Environment.userLevel,
        inAppHelper: Configuration.IAPManager.inAppHelper,
        receiptReader: Configuration.IAPManager.appReceiptReader,
        productsAtBuild: Configuration.IAPManager.productsAtBuild
    )

    static let sharedProcessor = ProfileProcessor(
        iapManager: sharedForApp,
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

            // copy app receipt URL to tunnel for beta eligibility
            if let appReceiptURL = Bundle.main.appStoreReceiptURL {
                let tunnelReceiptURL = BundleConfiguration.urlForAppGroupReceipt
                do {
                    try FileManager.default.removeItem(at: tunnelReceiptURL)
                    try FileManager.default.copyItem(at: appReceiptURL, to: tunnelReceiptURL)
                } catch {
                    pp_log(.App.iap, .error, "Unable to copy receipt URL to tunnel: \(error)")
                }
            }

            // ineligible, suppress on-demand rules
            if !iap.isEligible(for: .onDemand) {
                pp_log(.App.iap, .notice, "Ineligible, suppress on-demand rules")

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

private extension Configuration.Environment {
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

private extension Configuration.IAPManager {

    @MainActor
    static var appReceiptReader: AppReceiptReader {
        guard !Configuration.Environment.isFakeIAP else {
            guard let mockHelper = inAppHelper as? MockAppProductHelper else {
                fatalError("When .isFakeIAP, productHelper is expected to be MockAppProductHelper")
            }
            return mockHelper.receiptReader
        }
        return FallbackReceiptReader(
            main: StoreKitReceiptReader(),
            beta: releaseReceiptURL.map {
                KvittoReceiptReader(url: $0)
            }
        )
    }

    static var releaseReceiptURL: URL? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        return url
            .deletingLastPathComponent()
            .appendingPathComponent("receipt") // release receipt
    }
}
