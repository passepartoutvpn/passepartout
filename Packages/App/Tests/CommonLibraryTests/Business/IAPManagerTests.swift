//
//  IAPManagerTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/12/24.
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

import Combine
@testable import CommonIAP
@testable import CommonLibrary
import CommonUtils
import Foundation
import XCTest

@MainActor
final class IAPManagerTests: XCTestCase {
    private let olderBuildNumber = 500

    private let defaultBuildNumber = 1000

    private let newerBuildNumber = 1500

    private var subscriptions: Set<AnyCancellable> = []
}

// MARK: - Actions

extension IAPManagerTests {
    func test_givenProducts_whenFetchAppProducts_thenReturnsCorrespondingInAppProducts() async throws {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(receiptReader: reader)

        let appProducts: [AppProduct] = [
            .Essentials.iOS_macOS,
            .Donations.huge
        ]
        let inAppProducts = try await sut.purchasableProducts(for: appProducts)
        inAppProducts.enumerated().forEach {
            XCTAssertEqual($0.element.productIdentifier, appProducts[$0.offset].rawValue)
        }
    }

    func test_givenProducts_whenPurchase_thenIsAddedToPurchasedProducts() async throws {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: .max, products: [])
        let sut = IAPManager(receiptReader: reader)

        let appleTV: AppProduct = .Features.appleTV
        XCTAssertFalse(sut.purchasedProducts.contains(appleTV))
        do {
            let purchasable = try await sut.purchasableProducts(for: [appleTV])
            let purchasableAppleTV = try XCTUnwrap(purchasable.first)
            let result = try await sut.purchase(purchasableAppleTV)
            if result == .done {
                XCTAssertTrue(sut.purchasedProducts.contains(appleTV))
            } else {
                XCTFail("Unexpected purchase() result: \(result)")
            }
        } catch {
            XCTFail("Unexpected purchase() failure: \(error)")
        }
    }
}

// MARK: - Build products

extension IAPManagerTests {
    func test_givenBuildProducts_whenOlder_thenEssentialsVersion() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: olderBuildNumber, identifiers: [])
        let sut = IAPManager(receiptReader: reader) { build in
            if build <= self.defaultBuildNumber {
                return [.Essentials.iOS_macOS]
            }
            return []
        }
        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: AppFeature.essentialFeatures))
    }

    func test_givenBuildProducts_whenNewer_thenFreeVersion() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: newerBuildNumber, products: [])
        let sut = IAPManager(receiptReader: reader) { build in
            if build <= self.defaultBuildNumber {
                return [.Essentials.iOS_macOS]
            }
            return []
        }
        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.essentialFeatures))
    }
}

// MARK: - Eligibility

extension IAPManagerTests {
    func test_givenPurchasedFeature_whenReloadReceipt_thenIsEligible() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(receiptReader: reader)

        XCTAssertFalse(sut.isEligible(for: AppFeature.essentialFeatures))

        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Essentials.iOS_macOS])
        XCTAssertFalse(sut.isEligible(for: AppFeature.essentialFeatures))

        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: AppFeature.essentialFeatures))
    }

    func test_givenPurchasedFeatures_thenIsOnlyEligibleForFeatures() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [
            .Features.networkSettings
        ])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: .dns))
        XCTAssertTrue(sut.isEligible(for: .httpProxy))
        XCTAssertFalse(sut.isEligible(for: .onDemand))
        XCTAssertTrue(sut.isEligible(for: .routing))
        XCTAssertFalse(sut.isEligible(for: .sharing))
        XCTAssertFalse(sut.isEligible(for: AppFeature.essentialFeatures))
    }

    func test_givenPurchasedAndCancelledFeature_thenIsNotEligible() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(
            withBuild: defaultBuildNumber,
            products: [.Essentials.iOS_macOS],
            cancelledProducts: [.Essentials.iOS_macOS]
        )
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.essentialFeatures))
    }

    func test_givenFreeVersion_thenIsNotEligibleForAnyFeature() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        AppFeature.essentialFeatures.forEach {
            XCTAssertFalse(sut.isEligible(for: $0))
        }
    }

    func test_givenFreeVersion_thenIsNotEligibleForAppleTV() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: .appleTV))
    }

    func test_givenEssentialsVersion_thenIsEligibleForEssentialFeatures() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Essentials.iOS_macOS])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        let excluded: Set<AppFeature> = [
            .appleTV
        ]
        AppFeature.allCases.forEach {
            if AppFeature.essentialFeatures.contains($0) {
                XCTAssertTrue(sut.isEligible(for: $0))
                XCTAssertFalse(excluded.contains($0))
            } else {
                XCTAssertFalse(sut.isEligible(for: $0))
                XCTAssertTrue(excluded.contains($0))
            }
        }
    }

    func test_givenAppleTV_thenIsEligibleForAppleTVAndSharing() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Features.appleTV])
        let sut = IAPManager(receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: .appleTV))
        XCTAssertTrue(sut.isEligible(for: .sharing))
    }

    func test_givenPlatformEssentials_thenIsEssentialsForPlatform() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(receiptReader: reader)

#if os(macOS)
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Essentials.macOS, .Features.networkSettings])
        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: AppFeature.essentialFeatures))
#else
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Essentials.iOS, .Features.networkSettings])
        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: AppFeature.essentialFeatures))
#endif
    }

    func test_givenPlatformEssentials_thenIsNotEssentialsForOtherPlatform() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(receiptReader: reader)

#if os(macOS)
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Essentials.iOS, .Features.networkSettings])
        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.essentialFeatures))
#else
        await reader.setReceipt(withBuild: defaultBuildNumber, products: [.Essentials.macOS, .Features.networkSettings])
        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.essentialFeatures))
#endif
    }

    func test_givenUser_thenIsNotEligibleForFeedback() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(receiptReader: reader)
        XCTAssertFalse(sut.isEligibleForFeedback)
    }

    func test_givenBeta_thenIsEligibleForFeedback() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: .max, identifiers: [])
        let sut = IAPManager(customUserLevel: .beta, receiptReader: reader)
        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligibleForFeedback)
    }

    func test_givenPayingUser_thenIsEligibleForFeedback() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: .max, products: [.Essentials.iOS])
        let sut = IAPManager(receiptReader: reader)
        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligibleForFeedback)
    }
}

// MARK: - Suggestions

extension IAPManagerTests {
    func test_givenFree_thenSuggestsEssentialsAllAndPlatform() async {
        let sut = await IAPManager(products: [])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [
            .Essentials.iOS_macOS,
            .Essentials.iOS
        ])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [
            .Essentials.iOS_macOS,
            .Essentials.macOS
        ])
    }

    func test_givenEssentialsiOS_thenSuggestsEssentialsmacOS() async {
        let sut = await IAPManager(products: [.Essentials.iOS])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [
            .Essentials.macOS
        ])
    }

    func test_givenEssentialsmacOS_thenSuggestsEssentialsiOS() async {
        let sut = await IAPManager(products: [.Essentials.macOS])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [
            .Essentials.iOS
        ])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [])
    }

    func test_givenEssentialsiOSmacOS_thenSuggestsNothing() async {
        let sut = await IAPManager(products: [.Essentials.iOS, .Essentials.macOS])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [])
    }

    func test_givenEssentialsAll_thenSuggestsNothing() async {
        let sut = await IAPManager(products: [.Essentials.iOS_macOS])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [])
    }

    func test_givenAppleTV_thenSuggestsEssentialsAllAndPlatform() async {
        let sut = await IAPManager(products: [.Features.appleTV])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [
            .Essentials.iOS_macOS,
            .Essentials.iOS
        ])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [
            .Essentials.iOS_macOS,
            .Essentials.macOS
        ])
    }

    func test_givenFeature_thenSuggestsEssentialsAllAndPlatform() async {
        let sut = await IAPManager(products: [.Features.trustedNetworks])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [
            .Essentials.iOS_macOS,
            .Essentials.iOS
        ])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [
            .Essentials.iOS_macOS,
            .Essentials.macOS
        ])
    }

    func test_givenLifetime_thenSuggestsNothing() async {
        let sut = await IAPManager(products: [.Full.OneTime.lifetime])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [])
    }

    func test_givenRecurringMonthly_thenSuggestsNothing() async {
        let sut = await IAPManager(products: [.Full.Recurring.monthly])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [])
    }

    func test_givenRecurringYearly_thenSuggestsNothing() async {
        let sut = await IAPManager(products: [.Full.Recurring.yearly])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [])
    }

    func test_givenFree_whenWithRecurring_thenSuggestsEssentialsAndRecurring() async {
        let sut = await IAPManager(products: [])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS, withRecurring: true), [
            .Essentials.iOS_macOS,
            .Essentials.iOS,
            .Full.Recurring.yearly,
            .Full.Recurring.monthly
        ])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS, withRecurring: true), [
            .Essentials.iOS_macOS,
            .Essentials.macOS,
            .Full.Recurring.yearly,
            .Full.Recurring.monthly
        ])
    }

    func test_givenNonFree_whenWithRecurring_thenSuggestsEssentials() async {
        let sut = await IAPManager(products: [.Features.trustedNetworks])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS, withRecurring: true), [
            .Essentials.iOS_macOS,
            .Essentials.iOS
        ])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS, withRecurring: true), [
            .Essentials.iOS_macOS,
            .Essentials.macOS
        ])
    }
}

// MARK: - App level

extension IAPManagerTests {
    func test_givenBetaLevel_thenIsRestricted() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(customUserLevel: .beta, receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertTrue(sut.isBeta)
        XCTAssertTrue(sut.userLevel.isBeta)
    }

    func test_givenBetaLevel_thenIsNotEligibleForAllFeatures() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(customUserLevel: .beta, receiptReader: reader)

        await sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(for: AppFeature.allCases))
    }

    func test_givenBetaLevel_thenIsEligibleForUserLevelFeatures() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(customUserLevel: .beta, receiptReader: reader)

        let eligible = AppUserLevel.beta.features

        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: eligible))
    }

    func test_givenBetaLevel_thenIsEligibleForUnrestrictedFeature() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(customUserLevel: .beta, receiptReader: reader, unrestrictedFeatures: [.onDemand])

        var eligible = AppUserLevel.beta.features
        eligible.append(.onDemand)

        await sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(for: eligible))
    }

    func test_givenEssentialsLevel_thenIsEligibleForEssentialFeatures() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(customUserLevel: .essentials, receiptReader: reader)

        await sut.reloadReceipt()
        let excluded: Set<AppFeature> = [
            .appleTV
        ]
        AppFeature.allCases.forEach {
            if AppFeature.essentialFeatures.contains($0) {
                XCTAssertTrue(sut.isEligible(for: $0))
                XCTAssertFalse(excluded.contains($0))
            } else {
                XCTAssertFalse(sut.isEligible(for: $0))
                XCTAssertTrue(excluded.contains($0))
            }
        }
    }

    func test_givenCompleteLevel_thenIsEligibleForAnyFeature() async {
        let reader = FakeAppReceiptReader()
        let sut = IAPManager(customUserLevel: .complete, receiptReader: reader)

        await sut.reloadReceipt()
        AppFeature.allCases.forEach {
            XCTAssertTrue(sut.isEligible(for: $0))
        }
    }
}

// MARK: - Beta

extension IAPManagerTests {
    func test_givenChecker_whenReloadReceipt_thenIsBeta() async {
        let betaChecker = MockBetaChecker()
        betaChecker.isBeta = true
        let sut = IAPManager(receiptReader: FakeAppReceiptReader(), betaChecker: betaChecker)
        XCTAssertEqual(sut.userLevel, .undefined)
        await sut.reloadReceipt()
        XCTAssertEqual(sut.userLevel, .beta)
    }
}

// MARK: - Receipts

extension IAPManagerTests {
    func test_givenReceipts_whenReloadReceipt_thenPublishesEligibleFeatures() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: .max, products: [
            .Features.appleTV,
            .Features.trustedNetworks
        ])
        let sut = IAPManager(receiptReader: reader)

        let exp = expectation(description: "Eligible features")
        sut
            .$eligibleFeatures
            .dropFirst()
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &subscriptions)

        await sut.reloadReceipt()
        await fulfillment(of: [exp], timeout: CommonLibraryTests.timeout)

        XCTAssertEqual(sut.eligibleFeatures, [
            .appleTV,
            .onDemand,
            .sharing // implied by Apple TV purchase
        ])
    }

    func test_givenInvalidReceipts_whenReloadReceipt_thenSkipsInvalid() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: .max, products: [])
        await reader.addPurchase(with: "foobar")
        await reader.addPurchase(with: .Features.allProviders, expirationDate: Date().addingTimeInterval(-10))
        await reader.addPurchase(with: .Features.appleTV)
        await reader.addPurchase(with: .Features.networkSettings, expirationDate: Date().addingTimeInterval(10))
        await reader.addPurchase(with: .Essentials.iOS, cancellationDate: Date().addingTimeInterval(-60))

        let sut = IAPManager(receiptReader: reader)
        await sut.reloadReceipt()

        XCTAssertEqual(sut.eligibleFeatures, [
            .appleTV,
            .dns,
            .httpProxy,
            .routing,
            .sharing
        ])
    }
}

// MARK: - Observation

extension IAPManagerTests {
    func test_givenManager_whenObserveObjects_thenReloadsReceipt() async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: .max, products: [.Essentials.iOS_macOS])
        let sut = IAPManager(receiptReader: reader)

        XCTAssertEqual(sut.userLevel, .undefined)
        XCTAssertTrue(sut.eligibleFeatures.isEmpty)

        let exp = expectation(description: "Reload receipt")
        sut
            .$eligibleFeatures
            .dropFirst()
            .sink { _ in
                exp.fulfill()
            }
            .store(in: &subscriptions)

        sut.observeObjects()
        await fulfillment(of: [exp], timeout: CommonLibraryTests.timeout)

        XCTAssertNotEqual(sut.userLevel, .undefined)
        XCTAssertFalse(sut.eligibleFeatures.isEmpty)
    }
}

// MARK: -

private extension IAPManager {
    convenience init(
        customUserLevel: AppUserLevel? = nil,
        inAppHelper: (any AppProductHelper)? = nil,
        receiptReader: AppReceiptReader,
        betaChecker: BetaChecker? = nil,
        unrestrictedFeatures: Set<AppFeature> = [],
        productsAtBuild: BuildProducts<AppProduct>? = nil
    ) {
        self.init(
            customUserLevel: customUserLevel,
            inAppHelper: inAppHelper ?? FakeAppProductHelper(),
            receiptReader: receiptReader,
            betaChecker: betaChecker ?? TestFlightChecker(),
            unrestrictedFeatures: unrestrictedFeatures,
            productsAtBuild: productsAtBuild
        )
    }

    convenience init(products: Set<AppProduct>) async {
        let reader = FakeAppReceiptReader()
        await reader.setReceipt(withBuild: .max, products: products)
        self.init(receiptReader: reader)
        await reloadReceipt()
    }
}
