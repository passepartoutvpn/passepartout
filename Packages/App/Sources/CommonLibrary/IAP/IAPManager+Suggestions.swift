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
import PassepartoutKit

extension IAPManager {
    public func suggestedProducts() -> Set<AppProduct> {
#if os(iOS)
        suggestedProducts(for: .iOS, withRecurring: true)
#elseif os(macOS)
        suggestedProducts(for: .macOS, withRecurring: true)
#elseif os(tvOS)
        fatalError("tvOS: Do not suggest products, paywall unsupported")
#endif
    }
}

// for testing
extension IAPManager {
    enum Platform {
        case iOS

        case macOS
    }

    func suggestedProducts(
        for platform: Platform,
        withRecurring: Bool = false,
        asserting: Bool = false
    ) -> Set<AppProduct> {
        guard !purchasedProducts.contains(.Essentials.iOS_macOS) else {
            if asserting {
                assertionFailure("Suggesting 'Essentials' to former all platforms purchaser?")
            }
            return []
        }
        guard !purchasedProducts.contains(where: \.isFullVersion) else {
            if asserting {
                assertionFailure("Suggesting 'Essentials' to full version purchaser?")
            }
            return []
        }

        var suggested: Set<AppProduct> = []
        switch platform {
        case .iOS:
            guard !purchasedProducts.contains(.Essentials.iOS) else {
                if asserting {
                    assertionFailure("Suggesting 'Essentials iOS' to former iOS purchaser?")
                }
                return []
            }
            if !purchasedProducts.contains(.Essentials.macOS) {
                suggested.insert(.Essentials.iOS_macOS)
            }
            suggested.insert(.Essentials.iOS)
        case .macOS:
            guard !purchasedProducts.contains(.Essentials.macOS) else {
                if asserting {
                    assertionFailure("Suggesting 'Essentials macOS' to former macOS purchaser?")
                }
                return []
            }
            if !purchasedProducts.contains(.Essentials.iOS) {
                suggested.insert(.Essentials.iOS_macOS)
            }
            suggested.insert(.Essentials.macOS)
        }

        if withRecurring && purchasedProducts.isEmpty {
            suggested.insert(.Full.Recurring.yearly)
            suggested.insert(.Full.Recurring.monthly)
        }

        return suggested
    }
}
