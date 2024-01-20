//
//  ProductManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/19.
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

    @Published public private(set) var appType: AppType

    @Published public private(set) var isRefreshingProducts = false

    @Published public private(set) var products: [InAppProduct]

    //

    public var purchasedProductIdentifiers: Set<String> {
        Set(purchasedFeatures.map(\.rawValue))
    }

    private var purchasedAppBuild: Int?

    private var purchasedFeatures: Set<LocalProduct>

    private var purchaseDates: [LocalProduct: Date]

    public init(inApp: any LocalInApp,
                receiptReader: ReceiptReader,
                overriddenAppType: AppType? = nil,
                buildProducts: BuildProducts? = nil) {
        self.overriddenAppType = overriddenAppType
        self.receiptReader = receiptReader
        self.buildProducts = buildProducts ?? BuildProducts { _ in [] }
        appType = overriddenAppType ?? .undefined

        products = []
        self.inApp = inApp
        purchasedAppBuild = nil
        purchasedFeatures = []
        purchaseDates = [:]

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

    public func featureProducts(including: (LocalProduct) -> Bool) -> [InAppProduct] {
        inApp.products().filter {
            guard let p = LocalProduct(rawValue: $0.productIdentifier) else {
                return false
            }
            guard including(p) else {
                return false
            }
            guard p.isFeature else {
                return false
            }
            return true
        }
    }

    public func featureProducts(excluding: (LocalProduct) -> Bool) -> [InAppProduct] {
        inApp.products().filter {
            guard let p = LocalProduct(rawValue: $0.productIdentifier) else {
                return false
            }
            guard !excluding(p) else {
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
        if let purchasedAppBuild {
            if feature == .networkSettings && buildProducts.hasProduct(.networkSettings, atBuild: purchasedAppBuild) {
                return true
            }
        }
        pp_log.verbose("Eligibility: purchasedFeatures = \(purchasedFeatures)")
        pp_log.verbose("Eligibility: purchaseDates = \(purchaseDates)")
        pp_log.verbose("Eligibility: isIncludedInFullVersion(\(feature)) = \(isIncludedInFullVersion(feature))")
        if isIncludedInFullVersion(feature) {
            let isFullVersion = isFullVersion()
            let isActive = isActivePurchase(feature)
            pp_log.verbose("Eligibility: isFullVersion() = \(isFullVersion)")
            pp_log.verbose("Eligibility: isActivePurchase(\(feature)) = \(isActive)")
            return isFullVersion || isActive
        }
        let isActive = isActivePurchase(feature)
        pp_log.verbose("Eligibility: isActivePurchase(\(feature)) = \(isActive)")
        return isActive
    }

    public func isEligible(forProvider providerName: ProviderName) -> Bool {
        guard providerName != .oeck else {
            return true
        }
        return isEligible(forFeature: providerName.product)
    }

    public func isEligibleForFeedback() -> Bool {
        appType == .beta || isPayingUser()
    }
}

extension ProductManager {
    func isActivePurchase(_ feature: LocalProduct) -> Bool {
        purchasedFeatures.contains(feature)
    }

    func isActivePurchase(where predicate: (LocalProduct) -> Bool) -> Bool {
        purchasedFeatures.contains(where: predicate)
    }

    func isCurrentPlatformVersion() -> Bool {
        isActivePurchase(isMac ? .fullVersion_macOS : .fullVersion_iOS)
    }

    func isIncludedInFullVersion(_ feature: LocalProduct) -> Bool {
        switch appType {
        case .fullVersionPlusTV:
            return !feature.isLegacyPlatformVersion

        default:
            return !feature.isLegacyPlatformVersion && feature != .appleTV
        }
    }

    public func isFullVersion() -> Bool {
        if appType == .fullVersion || appType == .fullVersionPlusTV {
            pp_log.verbose("Eligibility: appType = .fullVersion")
            return true
        }
        pp_log.verbose("Eligibility: isCurrentPlatformVersion() = \(isCurrentPlatformVersion())")
        if isCurrentPlatformVersion() {
            return true
        }
        pp_log.verbose("Eligibility: isActivePurchase(.fullVersion) = \(isActivePurchase(.fullVersion))")
        return isActivePurchase(.fullVersion)
    }

    public func isPayingUser() -> Bool {
        !purchasedFeatures.isEmpty
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

// MARK: Purchasable products

extension ProductManager {

    // no purchase -> full version or platform version
    // purchased platform -> may only purchase other platform

    public func purchasableProducts(withFeature feature: LocalProduct?) -> [LocalProduct] {

        // separate purchase
        guard feature != .appleTV else {
            if hasPurchased(.appleTV) {
                return []
            }
            return [.appleTV]
        }

        if hasPurchased(.fullVersion) {
            return []
        }
#if targetEnvironment(macCatalyst)
        if hasPurchased(.fullVersion_macOS) {
            return []
        }
        if hasPurchased(.fullVersion_iOS) {
            return [.fullVersion_macOS]
        }
        return [.fullVersion, .fullVersion_macOS]
#else
        if hasPurchased(.fullVersion_iOS) {
            return []
        }
        if hasPurchased(.fullVersion_macOS) {
            return [.fullVersion_iOS]
        }
        return [.fullVersion, .fullVersion_iOS]
#endif
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
}
