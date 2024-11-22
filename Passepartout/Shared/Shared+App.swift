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
        betaChecker: Configuration.IAPManager.betaChecker,
        productsAtBuild: Configuration.IAPManager.productsAtBuild
    )

    static let sharedProcessor = InAppProcessor(
        iapManager: sharedForApp,
        title: {
            Configuration.ProfileManager.sharedTitle($0)
        },
        isIncluded: {
            Configuration.ProfileManager.isIncluded($0, $1)
        },
        preview: {
            ProfilePreview(
                id: $0.id,
                name: $0.name,
                subtitle: $0.localizedDescription(optionalStyle: .moduleTypes)
            )
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
        },
        verify: { iap, profile in
            do {
                try iap.verify(profile)
                return nil
            } catch AppError.ineligibleProfile(let requiredFeatures) {
                return requiredFeatures
            } catch {
                return nil
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
            guard let mockHelper = inAppHelper as? FakeAppProductHelper else {
                fatalError("When .isFakeIAP, productHelper is expected to be MockAppProductHelper")
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

    static var betaReceiptURL: URL? {
        Bundle.main.appStoreProductionReceiptURL
    }
}
