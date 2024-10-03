//
//  IAPManagerTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/12/24.
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

@testable import AppUI
import Foundation
import XCTest

final class IAPManagerTests: XCTestCase {
//    private let inApp = MockAppProductHelper()

    private let olderBuildNumber = 500

    private let defaultBuildNumber = 1000

    private let newerBuildNumber = 1500
}

@MainActor
extension IAPManagerTests {

    // MARK: Build products

    func test_givenBuildProducts_whenOlder_thenFullVersion() async {
        let reader = MockReceiptReader()
        await reader.setReceipt(withBuild: olderBuildNumber, products: [])
        let sut = IAPManager(receiptReader: reader) { build in
            if build <= self.defaultBuildNumber {
                return [.Full.allPlatforms]
            }
            return []
        }
        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
    }

    func test_givenBuildProducts_whenNewer_thenFreeVersion() async {
        let reader = MockReceiptReader()
        await reader.setReceipt(withBuild: newerBuildNumber, products: [])
        let sut = IAPManager(receiptReader: reader) { build in
            if build <= self.defaultBuildNumber {
                return [.Full.allPlatforms]
            }
            return []
        }
        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
    }

    // MARK: Eligibility

    func test_givenPurchasedFeature_whenReloadReceipt_thenIsEligible() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(receiptReader: reader)

        XCTAssertFalse(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))

        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Full.allPlatforms])
        XCTAssertFalse(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))

        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
    }

    func test_givenPurchasedFeatures_thenIsOnlyEligibleForFeatures() async {
        let reader = MockReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [
            .Features.siriShortcuts,
            .Features.networkSettings
        ])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: .dns))
        XCTAssertTrue(sut.isEligible(for: .httpProxy))
        XCTAssertFalse(sut.isEligible(for: .onDemand))
        XCTAssertTrue(sut.isEligible(for: .routing))
        XCTAssertFalse(sut.isEligible(for: .sharing))
        XCTAssertTrue(sut.isEligible(for: .siri))
        XCTAssertFalse(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
    }

    func test_givenPurchasedAndCancelledFeature_thenIsNotEligible() async {
        let reader = MockReceiptReader()
        await reader.setReceipt(
            withBuild: defaultBuildNumber,
            products: [.Full.allPlatforms],
            cancelledProducts: [.Full.allPlatforms]
        )
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
    }

    func test_givenFreeVersion_thenIsNotEligibleForAnyFeature() async {
        let reader = MockReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertFalse(sut.userLevel.isFullVersion)
        AppFeature.fullVersionFeaturesV2.forEach {
            XCTAssertFalse(sut.isEligible(for: $0))
        }
    }

    func test_givenFreeVersion_thenIsNotEligibleForAppleTV() async {
        let reader = MockReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: .appleTV))
    }

    func test_givenFullVersion_thenIsEligibleForAnyFeatureExceptAppleTV() async {
        let reader = MockReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Full.allPlatforms])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        AppFeature.fullVersionFeaturesV2.forEach {
            XCTAssertTrue(sut.isEligible(for: $0))
        }
        XCTAssertFalse(sut.isEligible(for: .appleTV))
    }

    func test_givenAppleTV_thenIsEligibleForAppleTV() async {
        let reader = MockReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Features.appleTV])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: .appleTV))
    }

    func test_givenPlatformVersion_thenIsFullVersionForPlatform() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(receiptReader: reader)

#if os(macOS)
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Full.macOS, .Features.networkSettings])
        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
#else
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Full.iOS, .Features.networkSettings])
        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
#endif
    }

    func test_givenPlatformVersion_thenIsNotFullVersionForOtherPlatform() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(receiptReader: reader)

#if os(macOS)
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Full.iOS, .Features.networkSettings])
        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
#else
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Full.macOS, .Features.networkSettings])
        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
#endif
    }

    // MARK: Purchasable

//    func test_givenNoPurchase_thenCanBuyFullAndPlatformVersion() {
//        let reader = MockReceiptReader()
//        reader.setReceipt(withBuild: defaultBuildNumber, products: [])
//        let sut = IAPManager(receiptReader: reader)
//
//#if targetEnvironment(macCatalyst)
//        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [.fullVersion, .fullVersion_macOS])
//#else
//        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [.fullVersion, .fullVersion_iOS])
//#endif
//    }
//
//    func test_givenFullVersion_thenCannotPurchase() {
//        let reader = MockReceiptReader()
//        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion])
//        let sut = IAPManager(receiptReader: reader)
//
//        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [])
//    }
//
//    func test_givenPlatformVersion_thenCannotPurchaseSamePlatform() {
//        let reader = MockReceiptReader()
//
//#if targetEnvironment(macCatalyst)
//        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_macOS])
//        let sut = IAPManager(receiptReader: reader)
//        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [])
//#else
//        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_iOS])
//        let sut = IAPManager(receiptReader: reader)
//        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [])
//#endif
//    }
//
//    func test_givenOtherPlatformVersion_thenCanOnlyPurchaseMissingPlatform() {
//        let reader = MockReceiptReader()
//
//#if targetEnvironment(macCatalyst)
//        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_iOS])
//        let sut = IAPManager(receiptReader: reader)
//        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [.fullVersion_macOS])
//#else
//        reader.setReceipt(withBuild: defaultBuildNumber, products: [.fullVersion_macOS])
//        let sut = IAPManager(receiptReader: reader)
//        XCTAssertEqual(sut.purchasableProducts(withFeature: nil), [.fullVersion_iOS])
//#endif
//    }
//
//    func test_givenAppleTV_whenDidNotPurchase_thenCanPurchase() {
//        let reader = MockReceiptReader()
//        reader.setReceipt(withBuild: defaultBuildNumber, products: [])
//        let sut = IAPManager(receiptReader: reader)
//
//        XCTAssertEqual(sut.purchasableProducts(withFeature: .appleTV), [.appleTV])
//    }
//
//    func test_givenAppleTV_whenDidPurchase_thenCannotPurchase() {
//        let reader = MockReceiptReader()
//        reader.setReceipt(withBuild: defaultBuildNumber, products: [.appleTV])
//        let sut = IAPManager(receiptReader: reader)
//
//        XCTAssertEqual(sut.purchasableProducts(withFeature: .appleTV), [])
//    }
//
    // MARK: App level

    func test_givenBetaApp_thenIsRestricted() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(customUserLevel: .beta, receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertTrue(sut.userLevel.isRestricted)
    }

    func test_givenBetaApp_thenIsNotEligibleForAnyFeature() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(customUserLevel: .beta, receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.fullVersionFeaturesV2))
    }

    func test_givenBetaApp_thenIsEligibleForUnrestrictedFeature() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(customUserLevel: .beta, receiptReader: reader, unrestrictedFeatures: [.onDemand])

        await sut.reloadReceipt()
        AppFeature.fullVersionFeaturesV2.forEach {
            if $0 == .onDemand {
                XCTAssertTrue(sut.isEligible(for: $0))
            } else {
                XCTAssertFalse(sut.isEligible(for: $0))
            }
        }
    }

    func test_givenFullApp_thenIsFullVersion() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(customUserLevel: .fullVersion, receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertTrue(sut.userLevel.isFullVersion)
    }

    func test_givenFullPlusTVApp_thenIsFullVersion() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(customUserLevel: .fullVersionPlusTV, receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertTrue(sut.userLevel.isFullVersion)
    }

    func test_givenFullApp_thenIsEligibleForAnyFeatureExceptAppleTV() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(customUserLevel: .fullVersion, receiptReader: reader)

        await sut.reloadReceipt()
        AppFeature.fullVersionFeaturesV2.forEach {
            XCTAssertTrue(sut.isEligible(for: $0))
        }
        XCTAssertFalse(sut.isEligible(for: .appleTV))
    }

    func test_givenFullPlusTVApp_thenIsEligibleForAnyFeature() async {
        let reader = MockReceiptReader()
        let sut = IAPManager(customUserLevel: .fullVersionPlusTV, receiptReader: reader)

        await sut.reloadReceipt()
        AppFeature.fullVersionFeaturesV2.forEach {
            XCTAssertTrue(sut.isEligible(for: $0))
        }
        XCTAssertTrue(sut.isEligible(for: .appleTV))
    }
}
