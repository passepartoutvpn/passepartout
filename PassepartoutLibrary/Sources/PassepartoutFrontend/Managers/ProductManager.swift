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
import PassepartoutCore
import PassepartoutProviders

@MainActor
public final class ProductManager: NSObject, ObservableObject {
    private let inApp: any LocalInApp

    private let receiptReader: ReceiptReader

    private let overriddenAppType: AppType?

    public let buildProducts: BuildProducts

    public let didRefundProducts = PassthroughSubject<Void, Never>()

    @Published public private(set) var appType: AppType

    @Published public private(set) var isRefreshingProducts = false

    @Published public private(set) var products: [InAppProduct]

    //

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

    public init(inApp: any LocalInApp,
                receiptReader: ReceiptReader,
                overriddenAppType: AppType? = nil,
                buildProducts: BuildProducts) {
        self.overriddenAppType = overriddenAppType
        self.receiptReader = receiptReader
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

        Task {
            await refreshProducts()

            let isBeta = await SandboxChecker().isBeta
            appType = overriddenAppType ?? (isBeta ? .beta : .freemium)
            pp_log.info("App type: \(appType)")
            reloadReceipt()
        }
    }

    // MARK: Main interface

    public func canMakePayments() -> Bool {
        inApp.canMakePurchases()
    }

    public func refreshProducts() async {
        let ids = LocalProduct.all
        guard !ids.isEmpty else {
            return
        }
        guard products.isEmpty else {
            pp_log.debug("In-app products already available, not refreshing")
            return
        }
        isRefreshingProducts = true
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

    public func product(withIdentifier identifier: LocalProduct) -> InAppProduct? {
        inApp.product(withIdentifier: identifier)
    }

    public func featureProducts(including: [LocalProduct]) -> [InAppProduct] {
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

    public func featureProducts(excluding: [LocalProduct]) -> [InAppProduct] {
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

    public func purchase(_ product: InAppProduct) async throws -> InAppPurchaseResult {
        guard let pid = LocalProduct(rawValue: product.productIdentifier) else {
            assertionFailure("Unrecognized product: \(product)")
            pp_log.warning("Unrecognized product: \(product)")
            return .cancelled
        }
        let result = try await inApp.purchase(productWithIdentifier: pid)
        reloadReceipt()
        return result
    }

    public func restorePurchases() async throws {
        try await inApp.restorePurchases()
    }

    public func hasPurchased(_ product: LocalProduct) -> Bool {
        isActivePurchase(product)
    }

    public func purchaseDate(forProduct product: LocalProduct) -> Date? {
        purchaseDates[product]
    }
}

// MARK: In-app eligibility

extension ProductManager {
    public func isEligible(forFeature feature: LocalProduct) -> Bool {
        if let purchasedAppBuild = purchasedAppBuild {
            if feature == .networkSettings && buildProducts.hasProduct(.networkSettings, atBuild: purchasedAppBuild) {
                return true
            }
        }
        if feature.isPlatformVersion {
            return isActivePurchase(feature)
        }
        return isFullVersion() || isActivePurchase(feature)
    }

    public func isEligible(forProvider providerName: ProviderName) -> Bool {
        guard providerName != .oeck else {
            return true
        }
        return isEligible(forFeature: providerName.product)
    }

    public func isEligibleForFeedback() -> Bool {
        appType == .beta || !purchasedFeatures.isEmpty
    }
}

extension ProductManager {
    func isActivePurchase(_ feature: LocalProduct) -> Bool {
        purchasedFeatures.contains(feature) && cancelledPurchases?.contains(feature) == false
    }

    func isActivePurchase(where predicate: (LocalProduct) -> Bool) -> Bool {
        purchasedFeatures.contains(where: predicate) && cancelledPurchases?.contains(where: predicate) == false
    }

    func isCurrentPlatformVersion() -> Bool {
        isActivePurchase(isMac ? .fullVersion_macOS : .fullVersion_iOS)
    }

    func isFullVersion() -> Bool {
        if appType == .fullVersion {
            return true
        }
        if isCurrentPlatformVersion() {
            return true
        }
        return isActivePurchase(.fullVersion)
    }
}

// MARK: Receipt

extension ProductManager {
    public func reloadReceipt(andNotify: Bool = true) {
        guard let receipt = receiptReader.receipt(for: appType) else {
            pp_log.error("Could not parse App Store receipt!")
            return
        }

        if let originalBuildNumber = receipt.originalBuildNumber {
            purchasedAppBuild = originalBuildNumber
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
        if let iapReceipts = receipt.purchaseReceipts {
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

// MARK: Helpers

private extension ProductManager {
    var isMac: Bool {
        #if targetEnvironment(macCatalyst)
        true
        #else
        false
        #endif
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
