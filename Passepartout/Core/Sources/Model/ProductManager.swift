//
//  ProductManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/19.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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
import StoreKit
import Convenience
import SwiftyBeaver
import Kvitto
import TunnelKit

private let log = SwiftyBeaver.self

public class ProductManager: NSObject {
    public struct Configuration {
        public let isBetaFullVersion: Bool

        public let lastFullVersionBuild: Int
        
        public init(
            isBetaFullVersion: Bool,
            lastFullVersionBuild: Int
        ) {
            self.isBetaFullVersion = isBetaFullVersion
            self.lastFullVersionBuild = lastFullVersionBuild
        }
    }
    
    public static let didReloadReceipt = Notification.Name("ProductManagerDidReloadReceipt")
    
    public static let didReviewPurchases = Notification.Name("ProductManagerDidReviewPurchases")
    
    public let cfg: Configuration

    private let inApp: InApp<Product>
    
    private var purchasedAppBuild: Int?
    
    private var purchasedFeatures: Set<Product>
    
    private var purchaseDates: [Product: Date]
    
    private var refreshRequest: SKReceiptRefreshRequest?
    
    private var restoreCompletionHandler: ((Error?) -> Void)?
    
    public init(_ cfg: Configuration) {
        self.cfg = cfg
        inApp = InApp()
        purchasedAppBuild = nil
        purchasedFeatures = []
        purchaseDates = [:]
        
        super.init()

        reloadReceipt()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    public var isBeta: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }

    public func listProducts(completionHandler: (([SKProduct]?, Error?) -> Void)?) {
        let products = Product.all
        guard !products.isEmpty else {
            completionHandler?(nil, nil)
            return
        }
        inApp.requestProducts(withIdentifiers: products, completionHandler: { _ in
            log.debug("In-app products: \(self.inApp.products.map { $0.productIdentifier })")

            completionHandler?(self.inApp.products, nil)
        }, failureHandler: {
            completionHandler?(nil, $0)
        })
    }

    public func product(withIdentifier identifier: Product) -> SKProduct? {
        return inApp.product(withIdentifier: identifier)
    }
    
    public func featureProducts(includingFullVersion: Bool) -> [SKProduct] {
        return inApp.products.filter {
            guard let p = Product(rawValue: $0.productIdentifier) else {
                return false
            }
            guard includingFullVersion || p != .fullVersion else {
                return false
            }
            guard p.isFeature else {
                return false
            }
            return true
        }
    }
    
    public func purchase(_ product: SKProduct, completionHandler: @escaping (InAppPurchaseResult, Error?) -> Void) {
        inApp.purchase(product: product) {
            if $0 == .success {
                self.reloadReceipt()
            }
            completionHandler($0, $1)
        }
    }
    
    public func restorePurchases(completionHandler: @escaping (Error?) -> Void) {
        restoreCompletionHandler = completionHandler
        refreshRequest = SKReceiptRefreshRequest()
        refreshRequest?.delegate = self
        refreshRequest?.start()
    }

    // MARK: In-app eligibility
    
    public func isFullVersion() -> Bool {
        #if os(iOS)
        if isBeta && cfg.isBetaFullVersion {
            return true
        }
        #else
        if cfg.isBetaFullVersion {
            return true
        }
        #endif
        return purchasedFeatures.contains(.fullVersion)
    }
    
    public func isEligible(forFeature feature: Product) -> Bool {
        return isFullVersion() || purchasedFeatures.contains(feature)
    }

    public func isEligible(forProvider metadata: Infrastructure.Metadata) -> Bool {
        return isFullVersion() || purchasedFeatures.contains(metadata.product)
    }

    public func isEligibleForFeedback() -> Bool {
        #if os(iOS)
        return isBeta || !purchasedFeatures.isEmpty
        #else
        return isFullVersion()
        #endif
    }
    
    public func purchaseDate(forProduct product: Product) -> Date? {
        return purchaseDates[product]
    }

    public func reloadReceipt(andNotify: Bool = true) {
        guard let url = Bundle.main.appStoreReceiptURL else {
            log.warning("No App Store receipt found!")
            return
        }
        guard let receipt = Receipt(contentsOfURL: url) else {
            log.error("Could not parse App Store receipt!")
            return
        }

        if let originalAppVersion = receipt.originalAppVersion, let buildNumber = Int(originalAppVersion) {
            purchasedAppBuild = buildNumber
        }
        purchasedFeatures.removeAll()

        if let buildNumber = purchasedAppBuild {
            log.debug("Original purchased build: \(buildNumber)")

            // treat former purchases as full versions
            if buildNumber <= cfg.lastFullVersionBuild {
                purchasedFeatures.insert(.fullVersion)
            }
        }
        if let iapReceipts = receipt.inAppPurchaseReceipts {
            purchaseDates.removeAll()
            
            log.debug("In-app receipts:")
            iapReceipts.forEach {
                guard let pid = $0.productIdentifier, let product = Product(rawValue: pid) else {
                    return
                }
                if let cancellationDate = $0.cancellationDate {
                    log.debug("\t\(pid) [cancelled on: \(cancellationDate)]")
                    return
                }
                if let purchaseDate = $0.originalPurchaseDate {
                    log.debug("\t\(pid) [purchased on: \(purchaseDate)]")
                    purchaseDates[product] = purchaseDate
                }
                purchasedFeatures.insert(product)
            }
        }
        log.info("Purchased features: \(purchasedFeatures)")
        
        if andNotify {
            NotificationCenter.default.post(name: ProductManager.didReloadReceipt, object: nil)
        }
    }
}

extension ProductManager: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        reloadReceipt()
    }
}

extension ProductManager: SKRequestDelegate {
    public func requestDidFinish(_ request: SKRequest) {
        reloadReceipt()
        inApp.restorePurchases { [weak self] (finished, _, error) in
            guard finished else {
                return
            }
            self?.restoreCompletionHandler?(error)
            self?.restoreCompletionHandler = nil
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        restoreCompletionHandler?(error)
        restoreCompletionHandler = nil
    }
}
