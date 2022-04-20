//
//  ProductManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/19.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

import Foundation
import PassepartoutCore
import StoreKit
import Kvitto

enum ProductError: Error {
    case uneligible
    
    case beta
}

@MainActor
class ProductManager: NSObject, ObservableObject {
    enum AppType: Int {
        case freemium = 0

        case beta = 1
        
        case fullVersion = 2
    }

    struct Configuration {
        let appType: AppType
        
        let lastFullVersionBuild: (Int, LocalProduct)
        
        let lastNetworkSettingsBuild: Int
        
        init(
            appType: AppType,
            lastFullVersionBuild: (Int, LocalProduct),
            lastNetworkSettingsBuild: Int
        ) {
            self.appType = appType
            self.lastFullVersionBuild = lastFullVersionBuild
            self.lastNetworkSettingsBuild = lastNetworkSettingsBuild
        }
    }
    
    let cfg: Configuration
    
    @Published private(set) var isRefreshingProducts = false

    @Published private(set) var products: [SKProduct]

    //
    
    private let inApp: InApp<LocalProduct>
    
    private var purchasedAppBuild: Int?
    
    private var purchasedFeatures: Set<LocalProduct>
    
    private var purchaseDates: [LocalProduct: Date]
    
    private var cancelledPurchases: Set<LocalProduct>
    
    private var refreshRequest: SKReceiptRefreshRequest?
    
    init(_ cfg: Configuration) {
        self.cfg = cfg
        products = []
        inApp = InApp()
        purchasedAppBuild = nil
        purchasedFeatures = []
        purchaseDates = [:]
        cancelledPurchases = []
        
        super.init()

        reloadReceipt()
        SKPaymentQueue.default().add(self)

        refreshProducts()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    func refreshProducts() {
        let ids = LocalProduct.all
        guard !ids.isEmpty else {
            return
        }
        guard products.isEmpty else {
            pp_log.debug("In-app products already available, not refreshing")
            return
        }
        isRefreshingProducts = true
        inApp.requestProducts(withIdentifiers: ids, completionHandler: { _ in
            pp_log.debug("In-app products: \(self.inApp.products.map { $0.productIdentifier })")

            self.products = self.inApp.products
            self.isRefreshingProducts = false
        }, failureHandler: {
            pp_log.warning("Unable to list products: \($0)")
            self.isRefreshingProducts = false
        })
    }

    func product(withIdentifier identifier: LocalProduct) -> SKProduct? {
        return inApp.product(withIdentifier: identifier)
    }
    
    func featureProducts(including: [LocalProduct]) -> [SKProduct] {
        return inApp.products.filter {
            guard let p = LocalProduct(rawValue: $0.productIdentifier) else {
                return false
            }
            guard including.contains(p) else {
                return false
            }
            guard p.isFeature else {
                return false
            }
            return true
        }
    }
    
    func featureProducts(excluding: [LocalProduct]) -> [SKProduct] {
        return inApp.products.filter {
            guard let p = LocalProduct(rawValue: $0.productIdentifier) else {
                return false
            }
            guard !excluding.contains(p) else {
                return false
            }
            guard p.isFeature else {
                return false
            }
            return true
        }
    }
    
    func purchase(_ product: SKProduct, completionHandler: @escaping (Result<InAppPurchaseResult, Error>) -> Void) {
        inApp.purchase(product: product) { result in
            if case .success = result {
                self.reloadReceipt()
            }
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }
    
    func restorePurchases(completionHandler: @escaping (Error?) -> Void) {
        inApp.restorePurchases { (finished, _, error) in
            guard finished else {
                return
            }
            DispatchQueue.main.async {
                completionHandler(error)
            }
        }
    }

    // MARK: In-app eligibility
    
    private func isCurrentPlatformVersion() -> Bool {
        #if targetEnvironment(macCatalyst)
        return purchasedFeatures.contains(.fullVersion_macOS)
        #else
        return purchasedFeatures.contains(.fullVersion_iOS)
        #endif
    }

    private func isFullVersion() -> Bool {
        if cfg.appType == .fullVersion {
            return true
        }
        if isCurrentPlatformVersion() {
            return true
        }
        return purchasedFeatures.contains(.fullVersion)
    }

    func isEligible(forFeature feature: LocalProduct) -> Bool {
        if let purchasedAppBuild = purchasedAppBuild {
            if feature == .networkSettings && purchasedAppBuild <= cfg.lastNetworkSettingsBuild {
                return true
            }
        }
        #if targetEnvironment(macCatalyst)
        return isFullVersion()
        #else
        return isFullVersion() || purchasedFeatures.contains(feature)
        #endif
    }

    func isEligible(forProvider providerName: ProviderName) -> Bool {
        isEligible(forFeature: providerName.product)
    }

    func isEligibleForFeedback() -> Bool {
        return cfg.appType == .beta || !purchasedFeatures.isEmpty
    }
    
    func hasPurchased(_ product: LocalProduct) -> Bool {
        return purchasedFeatures.contains(product)
    }

    func isCancelledPurchase(_ product: LocalProduct) -> Bool {
        return cancelledPurchases.contains(product)
    }
    
    func purchaseDate(forProduct product: LocalProduct) -> Date? {
        return purchaseDates[product]
    }

    func reloadReceipt(andNotify: Bool = true) {
        guard let url = Bundle.main.appStoreReceiptURL else {
            pp_log.warning("No App Store receipt found!")
            return
        }
        guard let receipt = Receipt(contentsOfURL: url) else {
            pp_log.error("Could not parse App Store receipt!")
            return
        }

        if let originalAppVersion = receipt.originalAppVersion, let buildNumber = Int(originalAppVersion) {
            purchasedAppBuild = buildNumber
        }
        purchasedFeatures.removeAll()
        cancelledPurchases.removeAll()

        if let buildNumber = purchasedAppBuild {
            pp_log.debug("Original purchased build: \(buildNumber)")

            // treat former purchases as full versions
            if buildNumber <= cfg.lastFullVersionBuild.0 {
                purchasedFeatures.insert(cfg.lastFullVersionBuild.1)
            }
        }
        if let iapReceipts = receipt.inAppPurchaseReceipts {
            purchaseDates.removeAll()
            
            pp_log.debug("In-app receipts:")
            iapReceipts.forEach {
                guard let pid = $0.productIdentifier, let product = LocalProduct(rawValue: pid) else {
                    return
                }
                if let cancellationDate = $0.cancellationDate {
                    pp_log.debug("\t\(pid) [cancelled on: \(cancellationDate)]")
                    cancelledPurchases.insert(product)
                    return
                }
                if let purchaseDate = $0.originalPurchaseDate {
                    pp_log.debug("\t\(pid) [purchased on: \(purchaseDate)]")
                    purchaseDates[product] = purchaseDate
                }
                purchasedFeatures.insert(product)
            }
        }
        pp_log.info("Purchased features: \(purchasedFeatures)")
        if andNotify {
            objectWillChange.send()
        }
    }
}

extension ProductManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadReceipt()
        }
    }
}

extension ProductManager {
    func hasRefunded() -> Bool {
        reloadReceipt(andNotify: false)
        let isEligibleForFullVersion = isFullVersion()
        let hasCancelledFullVersion: Bool
        let hasCancelledTrustedNetworks: Bool
        
        #if targetEnvironment(macCatalyst)
        hasCancelledFullVersion = !isEligibleForFullVersion && (isCancelledPurchase(.fullVersion) || isCancelledPurchase(.fullVersion_macOS))
        hasCancelledTrustedNetworks = false
        #else
        hasCancelledFullVersion = !isEligibleForFullVersion && (isCancelledPurchase(.fullVersion) || isCancelledPurchase(.fullVersion_iOS))
        hasCancelledTrustedNetworks = !isEligibleForFullVersion && isCancelledPurchase(.trustedNetworks)
        #endif
        
        // review features and potentially revert them if they were used (Siri is handled in AppDelegate)
        return hasCancelledFullVersion || hasCancelledTrustedNetworks
    }
}
