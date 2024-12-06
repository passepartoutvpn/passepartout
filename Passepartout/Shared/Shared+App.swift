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

import AppData
import AppDataPreferences
import CommonLibrary
import CommonUtils
import Foundation
import PassepartoutKit
import UITesting

extension IAPManager {
    static let sharedForApp = IAPManager(
        customUserLevel: Dependencies.IAPManager.customUserLevel,
        inAppHelper: Dependencies.IAPManager.simulatedInAppHelper,
        receiptReader: Dependencies.IAPManager.simulatedAppReceiptReader,
        betaChecker: Dependencies.IAPManager.betaChecker,
        productsAtBuild: Dependencies.IAPManager.productsAtBuild
    )
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

// MARK: - Dependencies

private extension Dependencies.IAPManager {
    static var customUserLevel: AppUserLevel? {
        guard let userLevelString = BundleConfiguration.mainIntegerIfPresent(for: .userLevel),
              let userLevel = AppUserLevel(rawValue: userLevelString) else {
            return nil
        }
        return userLevel
    }

    @MainActor
    static let simulatedInAppHelper: any AppProductHelper = {
        if AppCommandLine.contains(.fakeIAP) {
            return FakeAppProductHelper()
        }
        return inAppHelper
    }()

    @MainActor
    static var simulatedAppReceiptReader: AppReceiptReader {
        if AppCommandLine.contains(.fakeIAP) {
            guard let mockHelper = simulatedInAppHelper as? FakeAppProductHelper else {
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

    static var betaReceiptURL: URL? {
        Bundle.main.appStoreProductionReceiptURL
    }
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
