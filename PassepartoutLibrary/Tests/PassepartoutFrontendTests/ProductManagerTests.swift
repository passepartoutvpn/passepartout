//
//  ProductManagerTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/19/23.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

    private let noBuildProducts = BuildProducts { _ in [] }

    func test_givenBuildProducts_whenOlder_thenFullVersion() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: 500, products: [])
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: BuildProducts { build in
            if build <= 1000 {
                return [.fullVersion]
            }
            return []
        })
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))
    }

    func test_givenBuildProducts_whenNewer_thenFreeVersion() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: 1500, products: [])
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: BuildProducts { build in
            if build <= 1000 {
                return [.fullVersion]
            }
            return []
        })
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))
    }

    func test_givenPurchase_whenReload_thenCredited() {
        let reader = MockReceiptReader()
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: noBuildProducts)
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))

        reader.setReceipt(withBuild: 1500, products: [.fullVersion])
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))

        sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))
    }

    func test_givenPurchase_whenCancelled_thenRevoke() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: 1500, products: [.fullVersion])
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: noBuildProducts)
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))

        reader.setReceipt(withBuild: 1500, products: [.fullVersion], cancelledProducts: [.fullVersion])
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))

        sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))
    }

    func test_givenFeature_thenIsOnlyEligibleForFeature() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: 1500, products: [.siriShortcuts, .networkSettings])
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: noBuildProducts)

        XCTAssertTrue(sut.isEligible(forFeature: .siriShortcuts))
        XCTAssertTrue(sut.isEligible(forFeature: .networkSettings))
        XCTAssertFalse(sut.isEligible(forFeature: .trustedNetworks))
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))
        XCTAssertFalse(sut.isFullVersion())
    }

    func test_givenPlatformVersion_thenIsFullVersionForPlatform() {
        let reader = MockReceiptReader()
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: noBuildProducts)

        #if targetEnvironment(macCatalyst)
        reader.setReceipt(withBuild: 1500, products: [.fullVersion_macOS, .networkSettings])
        sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion_iOS))
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion_macOS))
        #else
        reader.setReceipt(withBuild: 1500, products: [.fullVersion_iOS, .networkSettings])
        sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion_iOS))
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion_macOS))
        #endif

        XCTAssertTrue(sut.isCurrentPlatformVersion())
        XCTAssertTrue(sut.isFullVersion())
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))
    }

    func test_givenFullVersion_thenIsEligibleForAnyFeature() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: 1500, products: [.fullVersion])
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: noBuildProducts)

        XCTAssertTrue(LocalProduct
            .allFeatures
            .filter { !$0.isPlatformVersion }
            .allSatisfy(sut.isEligible(forFeature:))
        )
    }

    func test_givenFreeVersion_thenIsNotEligibleForAnyFeature() {
        let reader = MockReceiptReader()
        reader.setReceipt(withBuild: 1500, products: [])
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: noBuildProducts)

        XCTAssertFalse(LocalProduct
            .allFeatures
            .allSatisfy(sut.isEligible(forFeature:))
        )
    }
}
