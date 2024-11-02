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

import Foundation
import PassepartoutKit
import CommonUtils

// FIXME: #424, reload receipt + objectWillChange on purchase/transactions

@MainActor
public final class IAPManager: ObservableObject {
    private let customUserLevel: AppUserLevel?

    private let receiptReader: any AppReceiptReader

    private let unrestrictedFeatures: Set<AppFeature>

    private let productsAtBuild: BuildProducts<AppProduct>?

    private(set) var userLevel: AppUserLevel

    private var purchasedAppBuild: Int?

    public private(set) var purchasedProducts: Set<AppProduct>

    private var eligibleFeatures: Set<AppFeature>

    public init(
        customUserLevel: AppUserLevel? = nil,
        receiptReader: any AppReceiptReader,
        unrestrictedFeatures: Set<AppFeature> = [],
        productsAtBuild: BuildProducts<AppProduct>? = nil
    ) {
        self.customUserLevel = customUserLevel
        self.receiptReader = receiptReader
        self.unrestrictedFeatures = unrestrictedFeatures
        self.productsAtBuild = productsAtBuild
        userLevel = .undefined
        purchasedProducts = []
        eligibleFeatures = []
    }

    public func reloadReceipt() async {
        await fetchLevelIfNeeded()

        if let receipt = await receiptReader.receipt(for: userLevel) {
            if let originalBuildNumber = receipt.originalBuildNumber {
                purchasedAppBuild = originalBuildNumber
            }
            purchasedProducts.removeAll()

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

            eligibleFeatures = Set(userLevel.features)
        }

        unrestrictedFeatures.forEach {
            eligibleFeatures.insert($0)
        }

        pp_log(.app, .notice, "Purchased products: \(purchasedProducts.map(\.rawValue))")
        pp_log(.app, .notice, "Eligible features: \(eligibleFeatures)")
        objectWillChange.send()
    }
}

private extension IAPManager {
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

// MARK: In-app eligibility

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

    public func paywallReason(forFeature feature: AppFeature) -> PaywallReason? {
        if isEligible(for: feature) {
            return nil
        }
        return isRestricted ? .restricted : .purchase(feature)
    }

    public func isPayingUser() -> Bool {
        !purchasedProducts.isEmpty
    }
}
