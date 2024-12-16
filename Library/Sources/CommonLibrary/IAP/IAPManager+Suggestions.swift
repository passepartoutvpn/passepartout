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

    public func suggestedProducts(for features: Set<AppFeature>) -> (oneTime: [AppProduct], recurring: [AppProduct])? {
        guard !features.isEmpty else {
            return nil
        }
        guard !eligibleFeatures.isSuperset(of: features) else {
            return nil
        }

        var oneTime: [AppProduct] = []
        let requiredFeatures = features.subtracting(eligibleFeatures)

        if isFullVersionPurchaser {
            if requiredFeatures == [.appleTV] {
                oneTime.append(.Features.appleTV)
            } else {
                assertionFailure("Full version purchaser requiring other than [.appleTV]")
            }
        } else { // !isFullVersionPurchaser
            if requiredFeatures == [.appleTV] {
                oneTime.append(.Features.appleTV)
                oneTime.append(.Full.OneTime.fullTV)
            } else if requiredFeatures.contains(.appleTV) {
                oneTime.append(.Full.OneTime.fullTV)
            } else {
                oneTime.append(.Full.OneTime.full)
                if !eligibleFeatures.contains(.appleTV) {
                    oneTime.append(.Full.OneTime.fullTV)
                }
            }
        }

        var recurring: [AppProduct] = []
        if oneTime.contains(.Full.OneTime.fullTV) {
            recurring = [.Full.Recurring.monthly, .Full.Recurring.yearly]
        }

        return (oneTime, recurring)
    }
}
