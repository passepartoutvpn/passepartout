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

    public enum SuggestionInclusion {
        case complete

        case singlePlatformEssentials
    }

    public func suggestedProducts(
        for features: Set<AppFeature>,
        including: Set<SuggestionInclusion> = [.complete]
    ) -> Set<AppProduct> {
#if os(iOS)
        suggestedProducts(for: features, on: .iOS, including: including)
#elseif os(macOS)
        suggestedProducts(for: features, on: .macOS, including: including)
#elseif os(tvOS)
        suggestedProducts(for: features, on: .tvOS, including: including)
#endif
    }
}

// for testing
extension IAPManager {

    // suggest the minimum set of products for the given required features
    func suggestedProducts(
        for features: Set<AppFeature>,
        on platform: Platform,
        including: Set<SuggestionInclusion>,
        asserting: Bool = false
    ) -> Set<AppProduct> {
        guard !purchasedProducts.contains(where: \.isComplete) else {
            if asserting {
                assertionFailure("Suggesting products to complete version purchaser?")
            }
            return []
        }

        var suggested: Set<AppProduct> = []

        // prioritize eligible features from non-essential products
        let nonEssentialProducts = features.flatMap(\.nonEssentialProducts)
        suggested.formUnion(nonEssentialProducts)
        let nonEssentialEligibleFeatures = Set(nonEssentialProducts.flatMap(\.features))

        //
        // suggest essential packages if:
        //
        // - never purchased any
        // - non-essential eligible features don't include required essential features
        //
        let essentialFeatures = features.filter(\.isEssential)
        if !didPurchaseEssentials(on: platform) &&
            !nonEssentialEligibleFeatures.isSuperset(of: essentialFeatures) {
            switch platform {
            case .iOS:
                // suggest both platforms if never purchased
                if !purchasedProducts.contains(.Essentials.macOS) {
                    suggested.insert(.Essentials.iOS_macOS)
                }
                // suggest iOS to former macOS purchasers
                let suggestsSinglePlatform = including.contains(.singlePlatformEssentials) || purchasedProducts.contains(.Essentials.macOS)
                if suggestsSinglePlatform && !purchasedProducts.contains(.Essentials.iOS) {
                    suggested.insert(.Essentials.iOS)
                }
            case .macOS:
                // suggest both platforms if never purchased
                if !purchasedProducts.contains(.Essentials.iOS) {
                    suggested.insert(.Essentials.iOS_macOS)
                }
                // suggest macOS to former iOS purchasers
                let suggestsSinglePlatform = including.contains(.singlePlatformEssentials) || purchasedProducts.contains(.Essentials.iOS)
                if suggestsSinglePlatform && !purchasedProducts.contains(.Essentials.macOS) {
                    suggested.insert(.Essentials.macOS)
                }
            case .tvOS:
                // suggest both platforms if never purchased
                if !purchasedProducts.contains(where: \.isEssentials) {
                    suggested.insert(.Essentials.iOS_macOS)
                }
            }
        }

        // FIXME: ###, not 100% sure about this
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
            // TODO: ###, this is somewhat possible with .json import
            suggestsComplete = !essentialFeatures.isEmpty
        default:
            suggestsComplete = true
        }

        // suggest complete packages if eligible
        if including.contains(.complete) && suggestsComplete && isEligibleForComplete {
            suggested.insert(.Complete.Recurring.yearly)
            suggested.insert(.Complete.Recurring.monthly)
            suggested.insert(.Complete.OneTime.lifetime)
        }

        // strip purchased (paranoid check)
        suggested.subtract(purchasedProducts)

        return suggested
    }

    func didPurchaseEssentials(on platform: Platform) -> Bool {
        switch platform {
        case .iOS:
            return purchasedProducts.contains(.Essentials.iOS) || purchasedProducts.contains(.Essentials.iOS_macOS)
        case .macOS:
            return purchasedProducts.contains(.Essentials.macOS) || purchasedProducts.contains(.Essentials.iOS_macOS)
        case .tvOS:
            return purchasedProducts.contains(where: \.isEssentials)
        }
    }
}
