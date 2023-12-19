//
//  ProductManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/19.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import Combine
import Foundation
import Kvitto
import PassepartoutLibrary

protocol LocalInApp: InAppProtocol where ProductIdentifier == LocalProduct {
}

extension StoreKitInApp: LocalInApp where ProductIdentifier == LocalProduct {
}

@MainActor
final class ProductManager: NSObject, ObservableObject {
    enum AppType: Int {
        case undefined = -1

        case freemium = 0

        case beta = 1

        case fullVersion = 2

        var isRestricted: Bool {
            switch self {
            case .undefined, .beta:
                return true

            default:
                return false
            }
        }
    }

    private let overriddenAppType: AppType?

    let buildProducts: BuildProducts

    let didRefundProducts = PassthroughSubject<Void, Never>()

    @Published private(set) var appType: AppType

    @Published private(set) var isRefreshingProducts = false

    @Published private(set) var products: [InAppProduct]

    //

    @MainActor
    private let inApp: any LocalInApp

    private var purchasedAppBuild: Int?

    private var purchasedFeatures: Set<LocalProduct>

    private var purchaseDates: [LocalProduct: Date]

    private var cancelledPurchases: Set<LocalProduct>? {
        willSet {
            guard cancelledPurchases != nil else {
                return
            }
            guard let newCancelledPurchases = newValue, newCancelledPurchases != cancelledPurchases else {
                pp_log.debug("No purchase was refunded")
                return
            }
            detectRefunds(newCancelledPurchases)
        }
    }

    init(inApp: any LocalInApp, overriddenAppType: AppType?, buildProducts: BuildProducts) {
        self.overriddenAppType = overriddenAppType
        self.buildProducts = buildProducts
        appType = .undefined

        products = []
        self.inApp = inApp
        purchasedAppBuild = nil
        purchasedFeatures = []
        purchaseDates = [:]
        cancelledPurchases = nil

        super.init()

        inApp.setTransactionsObserver { [weak self] in
            self?.reloadReceipt()
        }
        reloadReceipt()
        refreshProducts()

        Task {
            let isBeta = await SandboxChecker().isBeta
            appType = overriddenAppType ?? (isBeta ? .beta : .freemium)
            pp_log.info("App type: \(appType)")
            reloadReceipt()
        }
    }

    func canMakePayments() -> Bool {
        inApp.canMakePurchases()
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
        Task {
            do {
                let productsMap = try await inApp.requestProducts(withIdentifiers: ids)
                pp_log.debug("In-app products: \(productsMap.keys.map(\.rawValue))")

                products = Array(productsMap.values)
                isRefreshingProducts = false
            } catch {
                pp_log.warning("Unable to list products: \(error)")
                isRefreshingProducts = false
            }
        }
    }

    func product(withIdentifier identifier: LocalProduct) -> InAppProduct? {
        inApp.product(withIdentifier: identifier)
    }

    func featureProducts(including: [LocalProduct]) -> [InAppProduct] {
        inApp.products().filter {
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

    func featureProducts(excluding: [LocalProduct]) -> [InAppProduct] {
        inApp.products().filter {
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

    func purchase(_ product: InAppProduct, completionHandler: @escaping (Result<InAppPurchaseResult, Error>) -> Void) {
        guard let pid = LocalProduct(rawValue: product.productIdentifier) else {
            pp_log.warning("Unrecognized product: \(product)")
            return
        }
        Task {
            do {
                let result = try await inApp.purchase(productWithIdentifier: pid)
                reloadReceipt()
                completionHandler(.success(result))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    func restorePurchases(completionHandler: @escaping (Error?) -> Void) {
        Task {
            do {
                try await inApp.restorePurchases()
                completionHandler(nil)
            } catch {
                completionHandler(error)
            }
        }
    }

    // MARK: In-app eligibility

    private func isCurrentPlatformVersion() -> Bool {
        purchasedFeatures.contains(isMac ? .fullVersion_macOS : .fullVersion_iOS)
    }

    private func isFullVersion() -> Bool {
        if appType == .fullVersion {
            return true
        }
        if isCurrentPlatformVersion() {
            return true
        }
        return purchasedFeatures.contains(.fullVersion)
    }

    func isEligible(forFeature feature: LocalProduct) -> Bool {
        if let purchasedAppBuild = purchasedAppBuild {
            if feature == .networkSettings && buildProducts.hasProduct(.networkSettings, atBuild: purchasedAppBuild) {
                return true
            }
        }
        return isFullVersion() || purchasedFeatures.contains(feature)
    }

    func isEligible(forProvider providerName: ProviderName) -> Bool {
        guard providerName != .oeck else {
            return true
        }
        return isEligible(forFeature: providerName.product)
    }

    func isEligibleForFeedback() -> Bool {
        appType == .beta || !purchasedFeatures.isEmpty
    }

    func hasPurchased(_ product: LocalProduct) -> Bool {
        purchasedFeatures.contains(product)
    }

    func purchaseDate(forProduct product: LocalProduct) -> Date? {
        purchaseDates[product]
    }

    func reloadReceipt(andNotify: Bool = true) {
        guard let receipt else {
            pp_log.error("Could not parse App Store receipt!")
            return
        }

        if let originalAppVersion = receipt.originalAppVersion, let buildNumber = Int(originalAppVersion) {
            purchasedAppBuild = buildNumber
        }
        purchasedFeatures.removeAll()
        var newCancelledPurchases: Set<LocalProduct> = []

        if let buildNumber = purchasedAppBuild {
            pp_log.debug("Original purchased build: \(buildNumber)")

            // assume some purchases by build number
            buildProducts.products(atBuild: buildNumber).forEach {
                purchasedFeatures.insert($0)
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
                    newCancelledPurchases.insert(product)
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
        cancelledPurchases = newCancelledPurchases
    }
}

private extension ProductManager {
    var isMac: Bool {
        #if targetEnvironment(macCatalyst)
        true
        #else
        false
        #endif
    }

    var receipt: Receipt? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            pp_log.warning("No App Store receipt found!")
            return nil
        }
        let receipt = Receipt(contentsOfURL: url)

        // in TestFlight, attempt fallback to existing release receipt
        if appType == .beta {
            guard let receipt else {
                let releaseUrl = url.deletingLastPathComponent().appendingPathComponent("receipt")
                guard releaseUrl != url else {
                    assertionFailure("How can release URL be equal to sandbox URL in TestFlight?")
                    return nil
                }
                pp_log.warning("Sandbox receipt not found, falling back to Release receipt")
                return Receipt(contentsOfURL: releaseUrl)
            }
            return receipt
        }

        return receipt
    }

    func detectRefunds(_ refunds: Set<LocalProduct>) {
        let isEligibleForFullVersion = isFullVersion()
        let hasCancelledFullVersion: Bool
        let hasCancelledTrustedNetworks: Bool

        if isMac {
            hasCancelledFullVersion = !isEligibleForFullVersion && (
                refunds.contains(.fullVersion) || refunds.contains(.fullVersion_macOS)
            )
            hasCancelledTrustedNetworks = false
        } else {
            hasCancelledFullVersion = !isEligibleForFullVersion && (
                refunds.contains(.fullVersion) || refunds.contains(.fullVersion_iOS)
            )
            hasCancelledTrustedNetworks = !isEligibleForFullVersion && refunds.contains(.trustedNetworks)
        }

        // review features and potentially revert them if they were used (Siri is handled in AppDelegate)
        if hasCancelledFullVersion || hasCancelledTrustedNetworks {
            didRefundProducts.send()
        }
    }
}
