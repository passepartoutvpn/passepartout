//
//  IAPManager+Suggestions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/16/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

extension IAPManager {
    public enum Platform {
        case iOS

        case macOS

        case tvOS
    }

    public enum SuggestionFilter {
        case complete

        case singlePlatformEssentials
    }

    public func suggestedProducts(
        for features: Set<AppFeature>,
        filters: Set<SuggestionFilter> = [.complete]
    ) -> Set<AppProduct> {
#if os(iOS)
        suggestedProducts(for: features, on: .iOS, filters: filters)
#elseif os(macOS)
        suggestedProducts(for: features, on: .macOS, filters: filters)
#elseif os(tvOS)
        suggestedProducts(for: features, on: .tvOS, filters: filters)
#endif
    }
}

// for testing
extension IAPManager {

    // suggest the minimum set of products for the given required features
    func suggestedProducts(
        for features: Set<AppFeature>,
        on platform: Platform,
        filters: Set<SuggestionFilter>,
        asserting: Bool = false
    ) -> Set<AppProduct> {
        guard !purchasedProducts.contains(where: \.isComplete) else {
            if asserting {
                assertionFailure("Suggesting products to complete version purchaser?")
            }
            return []
        }

        var suggested: Set<AppProduct> = []

        // partition features
        let essential = features.filter(\.isEssential)
        let nonEssential = features.subtracting(essential)

        // prioritize non-essential products
        let nonEssentialProducts = nonEssential.reduce(into: Set<AppProduct>()) { group, element in
            element.individualProducts(for: platform).forEach {
                group.insert($0)
            }
        }
        suggested.formUnion(nonEssentialProducts)

        // infer eligible features so far
        let nonEssentialEligibleFeatures = nonEssentialProducts.flatMap {
            $0.features
        }

        // did purchase essentials for this platform?
        let didPurchaseEssentials = {
            switch platform {
            case .iOS:
                return purchasedProducts.contains(.Essentials.iOS) || purchasedProducts.contains(.Essentials.iOS_macOS)
            case .macOS:
                return purchasedProducts.contains(.Essentials.macOS) || purchasedProducts.contains(.Essentials.iOS_macOS)
            case .tvOS:
                return purchasedProducts.contains(where: \.isEssentials)
            }
        }()

        // suggest essential packages if non-essential don't include required essential features
        if !didPurchaseEssentials && !nonEssentialEligibleFeatures.contains(essential) {
            switch platform {
            case .iOS:
                if !purchasedProducts.contains(.Essentials.macOS) {
                    suggested.insert(.Essentials.iOS_macOS)
                }
                let suggestsSinglePlatform = filters.contains(.singlePlatformEssentials) || purchasedProducts.contains(.Essentials.macOS)
                if suggestsSinglePlatform && !purchasedProducts.contains(.Essentials.iOS) {
                    suggested.insert(.Essentials.iOS)
                }
            case .macOS:
                if !purchasedProducts.contains(.Essentials.iOS) {
                    suggested.insert(.Essentials.iOS_macOS)
                }
                let suggestsSinglePlatform = filters.contains(.singlePlatformEssentials) || purchasedProducts.contains(.Essentials.iOS)
                if suggestsSinglePlatform && !purchasedProducts.contains(.Essentials.macOS) {
                    suggested.insert(.Essentials.macOS)
                }
            case .tvOS:
                if !purchasedProducts.contains(where: \.isEssentials) {
                    suggested.insert(.Essentials.iOS_macOS)
                }
            }
        }

        let suggestsComplete: Bool
        switch platform {
        case .tvOS:
            //
            // "essential" features are not accessible from the
            // TV, therefore selling the "complete" packages is misleading
            // for TV-only customers. only offer them if some "essential"
            // feature is required, because it means that the iOS/macOS app
            // is also installed
            //
            suggestsComplete = !essential.isEmpty
        default:
            suggestsComplete = true
        }

        // suggest complete packages if eligible
        if filters.contains(.complete) && suggestsComplete && purchasedProducts.isEligibleForComplete {
            suggested.insert(.Complete.Recurring.yearly)
            suggested.insert(.Complete.Recurring.monthly)
            suggested.insert(.Complete.OneTime.lifetime)
        }

        return suggested
    }
}

private extension Collection where Element == AppProduct {

    //
    // allow purchasing complete products only if:
    //
    // - never bought complete products ('Forever', subscriptions)
    // - never bought 'Essentials' products (suggest individual features instead)
    // - never bought 'Apple TV' product (suggest 'Essentials' instead)
    //
    var isEligibleForComplete: Bool {
        !contains {
            $0.isComplete || $0.isEssentials || $0 == .Features.appleTV
        }
    }
}
