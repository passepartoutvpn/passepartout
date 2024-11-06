//
//  IAPManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/10/24.
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
import CommonUtils
import Foundation
import PassepartoutKit

@MainActor
public final class IAPManager: ObservableObject {
    private let customUserLevel: AppUserLevel?

    private let inAppHelper: any AppProductHelper

    private let receiptReader: AppReceiptReader

    private let unrestrictedFeatures: Set<AppFeature>

    private let productsAtBuild: BuildProducts<AppProduct>?

    private(set) var userLevel: AppUserLevel

    private var purchasedAppBuild: Int?

    public private(set) var purchasedProducts: Set<AppProduct>

    private var eligibleFeatures: Set<AppFeature>

    private var subscriptions: Set<AnyCancellable>

    public init(
        customUserLevel: AppUserLevel? = nil,
        inAppHelper: any AppProductHelper,
        receiptReader: AppReceiptReader,
        unrestrictedFeatures: Set<AppFeature> = [],
        productsAtBuild: BuildProducts<AppProduct>? = nil
    ) {
        self.customUserLevel = customUserLevel
        self.inAppHelper = inAppHelper
        self.receiptReader = receiptReader
        self.unrestrictedFeatures = unrestrictedFeatures
        self.productsAtBuild = productsAtBuild
        userLevel = .undefined
        purchasedProducts = []
        eligibleFeatures = []
        subscriptions = []

        observeObjects()
    }
}

// MARK: - Actions

extension IAPManager {
    public func purchasableProducts(for products: [AppProduct]) async -> [InAppProduct] {
        do {
            let inAppProducts = try await inAppHelper.fetchProducts()
            return products.compactMap {
                inAppProducts[$0]
            }
        } catch {
            pp_log(.app, .error, "Unable to fetch in-app products: \(error)")
            return []
        }
    }

    public func purchase(_ purchasableProduct: InAppProduct) async throws -> InAppPurchaseResult {
        let result = try await inAppHelper.purchase(purchasableProduct)
        if result == .done {
            await reloadReceipt()
        }
        return result
    }

    public func restorePurchases() async throws {
        try await inAppHelper.restorePurchases()
        await reloadReceipt()
    }

    public func reloadReceipt() async {
        purchasedAppBuild = nil
        purchasedProducts.removeAll()
        eligibleFeatures.removeAll()

        pp_log(.app, .notice, "Reload IAP receipt...")

        if let receipt = await receiptReader.receipt(at: userLevel) {
            if let originalBuildNumber = receipt.originalBuildNumber {
                purchasedAppBuild = originalBuildNumber
            }

            if let purchasedAppBuild {
                pp_log(.app, .info, "Original purchased build: \(purchasedAppBuild)")

                // assume some purchases by build number
                let entitled = productsAtBuild?(purchasedAppBuild) ?? []
                pp_log(.app, .notice, "Entitled features: \(entitled.map(\.rawValue))")

                entitled.forEach {
                    purchasedProducts.insert($0)
                }
            }
            if let iapReceipts = receipt.purchaseReceipts {
                pp_log(.app, .info, "In-app receipts:")
                iapReceipts.forEach {
                    guard let pid = $0.productIdentifier, let product = AppProduct(rawValue: pid) else {
                        return
                    }
                    if let expirationDate = $0.expirationDate {
                        let now = Date()
                        pp_log(.app, .debug, "\t\(pid) [expiration date: \(expirationDate), now: \(now)]")
                        if now >= expirationDate {
                            pp_log(.app, .info, "\t\(pid) [expired on: \(expirationDate)]")
                            return
                        }
                    }
                    if let cancellationDate = $0.cancellationDate {
                        pp_log(.app, .info, "\t\(pid) [cancelled on: \(cancellationDate)]")
                        return
                    }
                    if let purchaseDate = $0.originalPurchaseDate {
                        pp_log(.app, .info, "\t\(pid) [purchased on: \(purchaseDate)]")
                    }
                    purchasedProducts.insert(product)
                }
            }

            eligibleFeatures = purchasedProducts.reduce(into: []) { eligible, product in
                product.features.forEach {
                    eligible.insert($0)
                }
            }
        } else {
            pp_log(.app, .error, "Could not parse App Store receipt!")
        }

        userLevel.features.forEach {
            eligibleFeatures.insert($0)
        }
        unrestrictedFeatures.forEach {
            eligibleFeatures.insert($0)
        }

        pp_log(.app, .notice, "Reloaded IAP receipt:")
        pp_log(.app, .notice, "\tPurchased build number: \(purchasedAppBuild?.description ?? "unknown")")
        pp_log(.app, .notice, "\tPurchased products: \(purchasedProducts.map(\.rawValue))")
        pp_log(.app, .notice, "\tEligible features: \(eligibleFeatures)")

        objectWillChange.send()
    }
}

// MARK: - Eligibility

extension IAPManager {
    public var isRestricted: Bool {
        userLevel.isRestricted
    }

    public func isEligible(for feature: AppFeature) -> Bool {
        eligibleFeatures.contains(feature)
    }

    public func isEligible(for features: [AppFeature]) -> Bool {
        features.allSatisfy(eligibleFeatures.contains)
    }

    public func isEligible(forProvider providerId: ProviderID) -> Bool {
        if providerId == .oeck {
            return true
        }
        return isEligible(for: .providers)
    }

    public func isEligibleForFeedback() -> Bool {
#if os(tvOS)
        false
#else
        userLevel == .beta || isPayingUser()
#endif
    }

    public func paywallReason(forFeature feature: AppFeature, suggesting product: AppProduct?) -> PaywallReason? {
        if isEligible(for: feature) {
            return nil
        }
        return isRestricted ? .restricted : .purchase(feature, product)
    }

    public func isPayingUser() -> Bool {
        !purchasedProducts.isEmpty
    }
}

// MARK: - Observation

private extension IAPManager {
    func observeObjects() {
        Task {
            await fetchLevelIfNeeded()
            do {
                let products = try await inAppHelper.fetchProducts()
                pp_log(.app, .info, "Available in-app products: \(products.map(\.key))")

                inAppHelper
                    .didUpdate
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in
                        Task {
                            await self?.reloadReceipt()
                        }
                    }
                    .store(in: &subscriptions)

            } catch {
                pp_log(.app, .error, "Unable to fetch in-app products: \(error)")
            }
        }
    }

    func fetchLevelIfNeeded() async {
        guard userLevel == .undefined else {
            return
        }
        if let customUserLevel {
            userLevel = customUserLevel
            pp_log(.app, .info, "App level (custom): \(userLevel)")
        } else {
            let isBeta = await SandboxChecker().isBeta
            userLevel = isBeta ? .beta : .freemium
            pp_log(.app, .info, "App level: \(userLevel)")
        }
    }
}
