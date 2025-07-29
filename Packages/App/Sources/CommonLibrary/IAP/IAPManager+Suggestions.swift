// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonUtils

@available(*, deprecated, message: "FIXME: #1446, delete old paywall")
extension IAPManager {
    public enum SuggestionFilter {
        case excludingComplete

        case includingComplete

        case onlyComplete
    }

    public func suggestedProducts(filter: SuggestionFilter = .includingComplete) -> Set<AppProduct> {
#if os(iOS)
        suggestedProducts(for: .iOS, filter: filter)
#elseif os(macOS)
        suggestedProducts(for: .macOS, filter: filter)
#elseif os(tvOS)
        fatalError("tvOS: Do not suggest products, paywall unsupported")
#endif
    }
}

// for testing
@available(*, deprecated, message: "FIXME: #1446, delete old paywall")
extension IAPManager {
    func suggestedProducts(
        for platform: Platform,
        filter: SuggestionFilter,
        asserting: Bool = false
    ) -> Set<AppProduct> {
        guard !purchasedProducts.contains(.Essentials.iOS_macOS) else {
            if asserting {
                assertionFailure("Suggesting 'Essentials' to former all platforms purchaser?")
            }
            return []
        }
        guard !purchasedProducts.contains(where: \.isComplete) else {
            if asserting {
                assertionFailure("Suggesting 'Essentials' to complete version purchaser?")
            }
            return []
        }

        var suggested: Set<AppProduct> = []

        if filter != .onlyComplete {
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
            case .tvOS:
                fatalError("Do not present paywall on tvOS")
            }
        }

        if filter != .excludingComplete && purchasedProducts.isEligibleForComplete {
            suggested.insert(.Complete.Recurring.yearly)
            suggested.insert(.Complete.Recurring.monthly)
            suggested.insert(.Complete.OneTime.lifetime)
        }

        return suggested
    }
}

private extension Collection where Element == AppProduct {
    var isEligibleForComplete: Bool {
        !contains {
            $0.isComplete || $0.isEssentials || $0 == .Features.appleTV
        }
    }
}
