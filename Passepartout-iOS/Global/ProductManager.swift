//
//  ProductManager.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 4/6/19.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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
import PassepartoutCore

private let log = SwiftyBeaver.self

class ProductManager: NSObject {
    static let didReloadReceipt = Notification.Name("ProductManagerDidReloadReceipt")
    
    static let didReviewPurchases = Notification.Name("ProductManagerDidReviewPurchases")

    private static let lastFullVersionBuild = 2016 // 1.8.1

    static let shared = ProductManager()
    
    private let inApp: InApp<Product>
    
    private var purchasedAppBuild: Int?
    
    private var purchasedFeatures: Set<Product>
    
    private var refreshRequest: SKReceiptRefreshRequest?
    
    private var restoreCompletionHandler: ((Error?) -> Void)?
    
    private override init() {
        inApp = InApp()
        purchasedAppBuild = nil
        purchasedFeatures = []
        
        super.init()

        reloadReceipt()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func listProducts(completionHandler: (([SKProduct]?, Error?) -> Void)?) {
        inApp.requestProducts(withIdentifiers: Product.all, completionHandler: { _ in
            log.debug("In-app products: \(self.inApp.products.map { $0.productIdentifier })")
            
            completionHandler?(self.inApp.products, nil)
        }, failureHandler: {
            completionHandler?(nil, $0)
        })
    }

    func product(withIdentifier identifier: Product) -> SKProduct? {
        return inApp.product(withIdentifier: identifier)
    }
    
    func featureProducts(includingFullVersion: Bool) -> [SKProduct] {
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
    
    func purchase(_ product: SKProduct, completionHandler: @escaping (InAppPurchaseResult, Error?) -> Void) {
        inApp.purchase(product: product) {
            if $0 == .success {
                self.reloadReceipt()
            }
            completionHandler($0, $1)
        }
    }
    
    func restorePurchases(completionHandler: @escaping (Error?) -> Void) {
        restoreCompletionHandler = completionHandler
        refreshRequest = SKReceiptRefreshRequest()
        refreshRequest?.delegate = self
        refreshRequest?.start()
    }

    // MARK: In-app eligibility
    
    private func reloadReceipt(andNotify: Bool = true) {
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
            if buildNumber <= ProductManager.lastFullVersionBuild {
                purchasedFeatures.insert(.fullVersion)
            }
        }
        if let iapReceipts = receipt.inAppPurchaseReceipts {
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
                }
                purchasedFeatures.insert(product)
            }
        }
        log.info("Purchased features: \(purchasedFeatures)")
        
        if andNotify {
            NotificationCenter.default.post(name: ProductManager.didReloadReceipt, object: nil)
        }
    }

    func isFullVersion() -> Bool {
        if AppConstants.Flags.isBeta && AppConstants.Flags.isBetaFullVersion {
            return true
        }
        return purchasedFeatures.contains(.fullVersion)
    }
    
    func isEligible(forFeature feature: Product) -> Bool {
        return isFullVersion() || purchasedFeatures.contains(feature)
    }

    func isEligible(forProvider metadata: Infrastructure.Metadata) -> Bool {
        return isFullVersion() || purchasedFeatures.contains(metadata.product)
    }

    func isEligibleForFeedback() -> Bool {
        return AppConstants.Flags.isBeta || !purchasedFeatures.isEmpty
    }
    
    // MARK: Review
    
    func reviewPurchases() {
        let service = TransientStore.shared.service
        reloadReceipt(andNotify: false)
        var anyRefund = false

        // review features and potentially revert them if they were used (Siri is handled in AppDelegate)

        log.debug("Checking 'Trusted networks'")
        if !isEligible(forFeature: .trustedNetworks) {
            
            // reset trusted networks for ALL profiles (must load first)
            for key in service.allProfileKeys() {
                guard let profile = service.profile(withKey: key) else {
                    continue
                }
                if profile.trustedNetworks.includesMobile || !profile.trustedNetworks.includedWiFis.isEmpty {
                    profile.trustedNetworks.includesMobile = false
                    profile.trustedNetworks.includedWiFis.removeAll()
                    anyRefund = true
                }
            }
            if anyRefund {
                log.debug("\tRefunded")
            }
        }

        log.debug("Checking 'Unlimited hosts'")
        if !isEligible(forFeature: .unlimitedHosts) {
            let ids = service.ids(forContext: .host)
            if ids.count > AppConstants.InApp.limitedNumberOfHosts {
                for id in ids {
                    service.removeProfile(ProfileKey(.host, id))
                }
                log.debug("\tRefunded")
                anyRefund = true
            }
        }

        log.debug("Checking providers")
        for name in service.currentProviderNames() {
            guard let metadata = InfrastructureFactory.shared.metadata(forName: name) else {
                continue
            }
            if !isEligible(forProvider: metadata) {
                service.removeProfile(ProfileKey(name))
                log.debug("\tRefunded provider: \(name)")
                anyRefund = true
            }
        }
        
        guard anyRefund else {
            return
        }

        //

        // save reverts and remove fraud VPN profile
        TransientStore.shared.serialize(withProfiles: true)
        VPN.shared.uninstall(completionHandler: nil)

        NotificationCenter.default.post(name: ProductManager.didReviewPurchases, object: nil)
    }
}

extension ConnectionService {
    var hasReachedMaximumNumberOfHosts: Bool {
        let numberOfHosts = ids(forContext: .host).count
        return numberOfHosts >= AppConstants.InApp.limitedNumberOfHosts
    }
}

extension ProductManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        reloadReceipt()
    }
}

extension ProductManager: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {
        reloadReceipt()
        inApp.restorePurchases { [weak self] (finished, _, error) in
            guard finished else {
                return
            }
            self?.restoreCompletionHandler?(error)
            self?.restoreCompletionHandler = nil
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        restoreCompletionHandler?(error)
        restoreCompletionHandler = nil
    }
}
