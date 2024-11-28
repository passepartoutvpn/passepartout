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
import UITesting

extension IAPManager {
    static let sharedForApp = IAPManager(
        customUserLevel: Configuration.IAPManager.customUserLevel,
        inAppHelper: Configuration.IAPManager.simulatedInAppHelper,
        receiptReader: Configuration.IAPManager.simulatedAppReceiptReader,
        betaChecker: Configuration.IAPManager.betaChecker,
        productsAtBuild: Configuration.IAPManager.productsAtBuild
    )
}

// MARK: - Configuration

private extension Configuration.IAPManager {
    static var customUserLevel: AppUserLevel? {
        guard let userLevelString = BundleConfiguration.mainIntegerIfPresent(for: .userLevel),
              let userLevel = AppUserLevel(rawValue: userLevelString) else {
            return nil
        }
        return userLevel
    }

    @MainActor
    static let simulatedInAppHelper: any AppProductHelper = {
        guard !AppCommandLine.contains(.fakeIAP) else {
            return FakeAppProductHelper()
        }
        return inAppHelper
    }()

    @MainActor
    static var simulatedAppReceiptReader: AppReceiptReader {
        guard !AppCommandLine.contains(.fakeIAP) else {
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
