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

    private var pendingReceiptTask: Task<Void, Never>?

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
            pp_log(.App.iap, .error, "Unable to fetch in-app products: \(error)")
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
        if let pendingReceiptTask {
            await pendingReceiptTask.value
        }
        pendingReceiptTask = Task {
            await asyncReloadReceipt()
        }
        await pendingReceiptTask?.value
        pendingReceiptTask = nil
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

// MARK: - Receipt

private extension IAPManager {
    func asyncReloadReceipt() async {
        pp_log(.App.iap, .notice, "Start reloading in-app receipt...")

        purchasedAppBuild = nil
        purchasedProducts.removeAll()
        eligibleFeatures.removeAll()

        if let receipt = await receiptReader.receipt(at: userLevel) {
            if let originalBuildNumber = receipt.originalBuildNumber {
                purchasedAppBuild = originalBuildNumber
            }

            if let purchasedAppBuild {
                pp_log(.App.iap, .info, "Original purchased build: \(purchasedAppBuild)")

                // assume some purchases by build number
                let entitled = productsAtBuild?(purchasedAppBuild) ?? []
                pp_log(.App.iap, .notice, "Entitled features: \(entitled.map(\.rawValue))")

                entitled.forEach {
                    purchasedProducts.insert($0)
                }
            }
            if let iapReceipts = receipt.purchaseReceipts {
                pp_log(.App.iap, .info, "Process in-app purchase receipts...")

                let products: [AppProduct] = iapReceipts.compactMap {
                    guard let pid = $0.productIdentifier else {
                        return nil
                    }
                    guard let product = AppProduct(rawValue: pid) else {
                        pp_log(.App.iap, .debug, "\tDiscard unknown product identifier: \(pid)")
                        return nil
                    }
                    if let expirationDate = $0.expirationDate {
                        let now = Date()
                        pp_log(.App.iap, .debug, "\t\(pid) [expiration date: \(expirationDate), now: \(now)]")
                        if now >= expirationDate {
                            pp_log(.App.iap, .info, "\t\(pid) [expired on: \(expirationDate)]")
                            return nil
                        }
                    }
                    if let cancellationDate = $0.cancellationDate {
                        pp_log(.App.iap, .info, "\t\(pid) [cancelled on: \(cancellationDate)]")
                        return nil
                    }
                    if let purchaseDate = $0.originalPurchaseDate {
                        pp_log(.App.iap, .info, "\t\(pid) [purchased on: \(purchaseDate)]")
                    }
                    return product
                }

                products.forEach {
                    purchasedProducts.insert($0)
                }
            }

            eligibleFeatures = purchasedProducts.reduce(into: []) { eligible, product in
                product.features.forEach {
                    eligible.insert($0)
                }
            }
        } else {
            pp_log(.App.iap, .error, "Could not parse App Store receipt!")
        }

        userLevel.features.forEach {
            eligibleFeatures.insert($0)
        }
        unrestrictedFeatures.forEach {
            eligibleFeatures.insert($0)
        }

        pp_log(.App.iap, .notice, "Finished reloading in-app receipt for user level \(userLevel)")
        pp_log(.App.iap, .notice, "\tPurchased build number: \(purchasedAppBuild?.description ?? "unknown")")
        pp_log(.App.iap, .notice, "\tPurchased products: \(purchasedProducts.map(\.rawValue))")
        pp_log(.App.iap, .notice, "\tEligible features: \(eligibleFeatures)")

        objectWillChange.send()
    }
}

// MARK: - Observation

private extension IAPManager {
    func observeObjects() {
        Task {
            await fetchLevelIfNeeded()
            await reloadReceipt()
            do {
                let products = try await inAppHelper.fetchProducts()
                pp_log(.App.iap, .info, "Available in-app products: \(products.map(\.key))")

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
                pp_log(.App.iap, .error, "Unable to fetch in-app products: \(error)")
            }
        }
    }

    func fetchLevelIfNeeded() async {
        guard userLevel == .undefined else {
            return
        }
        if let customUserLevel {
            userLevel = customUserLevel
            pp_log(.App.iap, .info, "App level (custom): \(userLevel)")
        } else {
            let isBeta = await SandboxChecker().isBeta
            userLevel = isBeta ? .beta : .freemium
            pp_log(.App.iap, .info, "App level: \(userLevel)")
        }
    }
}
