//
//  IAPManager+Suggestions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/16/24.
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

import CommonIAP
import CommonUtils
import Foundation
import PassepartoutKit

extension IAPManager {
    public var isFullVersionPurchaser: Bool {
        purchasedProducts.contains(.Full.OneTime.full) || purchasedProducts.contains(.Full.OneTime.fullTV) || (purchasedProducts.contains(.Full.OneTime.iOS) && purchasedProducts.contains(.Full.OneTime.macOS))
    }

    public func suggestedProducts(for requiredFeatures: Set<AppFeature>) -> [AppProduct]? {
        guard !requiredFeatures.isEmpty else {
            return nil
        }
        guard !eligibleFeatures.isSuperset(of: requiredFeatures) else {
            return nil
        }

        var products: [AppProduct] = []
        let ineligibleFeatures = requiredFeatures.subtracting(eligibleFeatures)

        if isFullVersionPurchaser {
            if ineligibleFeatures == [.appleTV] {
                products.append(.Features.appleTV)
            } else {
                assertionFailure("Full version purchaser requiring other than [.appleTV]")
            }
        } else { // !isFullVersionPurchaser
            if ineligibleFeatures == [.appleTV] {
                products.append(.Features.appleTV)
                products.append(.Full.OneTime.fullTV)
            } else if ineligibleFeatures.contains(.appleTV) {
                products.append(.Full.OneTime.fullTV)
            } else {
                if !eligibleFeatures.contains(.appleTV) {
                    products.append(.Full.OneTime.fullTV)
                }
                products.append(.Full.OneTime.full)
            }
        }

        if products.contains(.Full.OneTime.fullTV) {
            products.insert(.Full.Recurring.monthly, at: 0)
            products.insert(.Full.Recurring.yearly, at: 0)
        }

        return products
    }
}
