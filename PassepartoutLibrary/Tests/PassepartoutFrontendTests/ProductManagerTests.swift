//
//  ProductManagerTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/19/23.
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
@testable import PassepartoutFrontend
import XCTest

@MainActor
final class ProductManagerTests: XCTestCase {
    private let inApp = MockInApp()

    private let olderBuildNumber = 500

    private let defaultBuildNumber = 1000

    private let newerBuildNumber = 1500

    // MARK: Build products

    func test_givenBuildProducts_whenOlder_thenFullVersion() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: olderBuildNumber, products: [])
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: BuildProducts { build in
            if build <= self.defaultBuildNumber {
                return [.fullVersion]
            }
            return []
        })
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))
    }

    func test_givenBuildProducts_whenNewer_thenFreeVersion() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: newerBuildNumber, products: [])
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: BuildProducts { build in
            if build <= self.defaultBuildNumber {
                return [.fullVersion]
            }
            return []
        })
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))
    }

    // MARK: Eligibility

    func test_givenPurchasedFeature_whenReloadReceipt_thenIsEligible() {
        let reader = MockReceiptReader()
        let sut = ProductManager(inApp: inApp, receiptReader: reader)
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))

        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion])
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))

        sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))
    }

    func test_givenPurchasedFeatures_thenIsOnlyEligibleForFeatures() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.siriShortcuts, .networkSettings])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertTrue(sut.isEligible(forFeature: .siriShortcuts))
        XCTAssertTrue(sut.isEligible(forFeature: .networkSettings))
        XCTAssertFalse(sut.isEligible(forFeature: .trustedNetworks))
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))
        XCTAssertFalse(sut.isFullVersion())
    }

    func test_givenPurchasedAndCancelledFeature_thenIsNotEligible() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion], cancelledProducts: [.fullVersion])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))
    }

    func test_givenFreeVersion_thenIsNotEligibleForAnyFeature() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertFalse(sut.isFullVersion())
        XCTAssertTrue(LocalProduct
            .allFeatures
            .allSatisfy { !sut.isEligible(forFeature: $0) }
        )
    }

    func test_givenFreeVersion_thenIsNotEligibleForAppleTV() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertFalse(sut.isEligible(forFeature: .appleTV))
    }

    func test_givenFullVersion_thenIsEligibleForAnyFeatureExceptAppleTV() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertTrue(sut.isFullVersion())
        LocalProduct
            .allFeatures
            .forEach {
                guard $0 != .appleTV && !$0.isLegacyPlatformVersion else {
                    XCTAssertFalse(sut.isEligible(forFeature: $0), $0.rawValue)
                    return
                }
                XCTAssertTrue(sut.isEligible(forFeature: $0), $0.rawValue)
            }
    }

    func test_givenFullVersion_thenIsNotEligibleForAppleTV() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertFalse(sut.isEligible(forFeature: .appleTV))
    }

    func test_givenAppleTV_thenIsEligibleForAppleTV() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.appleTV])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertTrue(sut.isEligible(forFeature: .appleTV))
    }

    func test_givenPlatformVersion_thenIsFullVersionForPlatform() {
        let reader = MockReceiptReader()
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

#if targetEnvironment(macCatalyst)
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_macOS, .networkSettings])
        sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion_iOS))
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion_macOS))
#else
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_iOS, .networkSettings])
        sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion_iOS))
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion_macOS))
#endif

        XCTAssertTrue(sut.isCurrentPlatformVersion())
        XCTAssertTrue(sut.isFullVersion())
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))
    }

    // MARK: Purchasable

    func test_givenNoPurchase_thenCanBuyFullAndPlatformVersion() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

#if targetEnvironment(macCatalyst)
        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [.fullVersion, .fullVersion_macOS])
#else
        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [.fullVersion, .fullVersion_iOS])
#endif
    }

    func test_givenFullVersion_thenCannotPurchase() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [])
    }

    func test_givenPlatformVersion_thenCannotPurchaseSamePlatform() {
        let reader = MockReceiptReader()

#if targetEnvironment(macCatalyst)
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_macOS])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)
        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [])
#else
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_iOS])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)
        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [])
#endif
    }

    func test_givenOtherPlatformVersion_thenCanOnlyPurchaseMissingPlatform() {
        let reader = MockReceiptReader()

#if targetEnvironment(macCatalyst)
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_iOS])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)
        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [.fullVersion_macOS])
#else
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_macOS])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)
        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [.fullVersion_iOS])
#endif
    }

    func test_givenAppleTV_whenDidNotPurchase_thenCanPurchase() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertEqual(sut.purchasableProducts(withFeature: .appleTV), [.appleTV])
    }

    func test_givenAppleTV_whenDidPurchase_thenCannotPurchase() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: defaultBuildNumber, products: [.appleTV])
        let sut = ProductManager(inApp: inApp, receiptReader: reader)

        XCTAssertEqual(sut.purchasableProducts(withFeature: .appleTV), [])
    }

    // MARK: App type

    func test_givenBetaApp_thenIsNotEligibleForAnyFeature() {
        let reader = MockReceiptReader()
        let sut = ProductManager(inApp: inApp, receiptReader: reader, overriddenAppType: .beta)

        XCTAssertTrue(LocalProduct
            .allFeatures
            .allSatisfy { !sut.isEligible(forFeature: $0) }
        )
    }

    func test_givenFullApp_thenIsEligibleForAnyFeatureExceptAppleTV() {
        let reader = MockReceiptReader()
        let sut = ProductManager(inApp: inApp, receiptReader: reader, overriddenAppType: .fullVersion)

        LocalProduct
            .allFeatures
            .forEach {
                guard !$0.isLegacyPlatformVersion, $0 != .appleTV else {
                    XCTAssertFalse(sut.isEligible(forFeature: $0), $0.rawValue)
                    return
                }
                XCTAssertTrue(sut.isEligible(forFeature: $0), $0.rawValue)
            }
    }

    func test_givenFullPlusTVApp_thenIsEligibleForAnyFeature() {
        let reader = MockReceiptReader()
        let sut = ProductManager(inApp: inApp, receiptReader: reader, overriddenAppType: .fullVersionPlusTV)

        LocalProduct
            .allFeatures
            .forEach {
                guard !$0.isLegacyPlatformVersion else {
                    XCTAssertFalse(sut.isEligible(forFeature: $0), $0.rawValue)
                    return
                }
                XCTAssertTrue(sut.isEligible(forFeature: $0), $0.rawValue)
            }
    }
}
