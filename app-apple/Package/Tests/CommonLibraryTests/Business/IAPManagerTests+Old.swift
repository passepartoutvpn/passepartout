// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

@testable import CommonLibrary
import XCTest

@MainActor
final class IAPManagerOldSuggestionsTests: XCTestCase {
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
        let sut = await IAPManager(products: [.Complete.OneTime.lifetime])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [])
    }

    func test_givenRecurringMonthly_thenSuggestsNothing() async {
        let sut = await IAPManager(products: [.Complete.Recurring.monthly])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [])
    }

    func test_givenRecurringYearly_thenSuggestsNothing() async {
        let sut = await IAPManager(products: [.Complete.Recurring.yearly])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS), [])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS), [])
    }

    func test_givenFree_whenWithComplete_thenSuggestsEssentialsAndComplete() async {
        let sut = await IAPManager(products: [])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS, filter: .includingComplete), [
            .Essentials.iOS_macOS,
            .Essentials.iOS,
            .Complete.Recurring.yearly,
            .Complete.Recurring.monthly,
            .Complete.OneTime.lifetime
        ])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS, filter: .includingComplete), [
            .Essentials.iOS_macOS,
            .Essentials.macOS,
            .Complete.Recurring.yearly,
            .Complete.Recurring.monthly,
            .Complete.OneTime.lifetime
        ])
    }

    func test_givenOldProducts_whenWithComplete_thenSuggestsEssentialsAndComplete() async {
        let sut = await IAPManager(products: [.Features.trustedNetworks])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS, filter: .includingComplete), [
            .Essentials.iOS_macOS,
            .Essentials.iOS,
            .Complete.OneTime.lifetime,
            .Complete.Recurring.monthly,
            .Complete.Recurring.yearly
        ])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS, filter: .includingComplete), [
            .Essentials.iOS_macOS,
            .Essentials.macOS,
            .Complete.OneTime.lifetime,
            .Complete.Recurring.monthly,
            .Complete.Recurring.yearly
        ])
    }

    func test_givenNewProducts_whenWithComplete_thenSuggestsEssentials() async {
        let sut = await IAPManager(products: [.Features.appleTV])
        XCTAssertEqual(sut.suggestedProducts(for: .iOS, filter: .includingComplete), [
            .Essentials.iOS_macOS,
            .Essentials.iOS
        ])
        XCTAssertEqual(sut.suggestedProducts(for: .macOS, filter: .includingComplete), [
            .Essentials.iOS_macOS,
            .Essentials.macOS
        ])
    }
}

private extension IAPManager {
    func suggestedProducts(for platform: Platform) -> Set<AppProduct> {
        suggestedProducts(for: platform, filter: .excludingComplete)
    }
}
