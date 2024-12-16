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

    public func suggestedProducts(for features: Set<AppFeature>) -> [AppProduct] {
        guard !features.isEmpty else {
            return []
        }
        guard !eligibleFeatures.isSuperset(of: features) else {
            return []
        }

        var list: [AppProduct] = []
        let requiredFeatures = features.subtracting(eligibleFeatures)

        if isFullVersionPurchaser {
            if requiredFeatures == [.appleTV] {
                list.append(.Features.appleTV)
            } else {
                assertionFailure("Full version purchaser requiring other than [.appleTV]")
            }
        } else { // !isFullVersionPurchaser
            if requiredFeatures == [.appleTV] {
                list.append(.Features.appleTV)
                list.append(.Full.OneTime.fullTV)
            } else if requiredFeatures.contains(.appleTV) {
                list.append(.Full.OneTime.fullTV)
            } else {
                list.append(.Full.OneTime.full)
                if !eligibleFeatures.contains(.appleTV) {
                    list.append(.Full.OneTime.fullTV)
                }
            }
        }

        if list.contains(.Full.OneTime.fullTV) {
            list.append(.Full.Recurring.monthly)
            list.append(.Full.Recurring.yearly)
        }

        return list
    }
}
