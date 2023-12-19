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
@testable import Passepartout
@testable import PassepartoutLibrary
import XCTest

@MainActor
final class ProductManagerTests: XCTestCase {
    private let inApp = MockInApp()

    func test_givenBuildProducts_whenOlder_thenFullVersion() {
        let reader = MockReceiptReader()
        reader.customReceipt = InAppReceipt(originalBuildNumber: 500, purchaseReceipts: nil)
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
        reader.customReceipt = InAppReceipt(originalBuildNumber: 1500, purchaseReceipts: nil)
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
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: BuildProducts { _ in [] })
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))

        reader.customReceipt = InAppReceipt(originalBuildNumber: 1500, purchaseReceipts: [
            .init(productIdentifier: LocalProduct.fullVersion.rawValue, cancellationDate: nil, originalPurchaseDate: nil)
        ])
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))

        sut.reloadReceipt()
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))
    }

    func test_givenPurchase_whenCancelled_thenRevoke() {
        let reader = MockReceiptReader()
        reader.customReceipt = InAppReceipt(originalBuildNumber: 1500, purchaseReceipts: [
            .init(productIdentifier: LocalProduct.fullVersion.rawValue, cancellationDate: nil, originalPurchaseDate: nil)
        ])
        let sut = ProductManager(inApp: inApp, receiptReader: reader, buildProducts: BuildProducts { _ in [] })
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))

        reader.customReceipt = InAppReceipt(originalBuildNumber: 1500, purchaseReceipts: [
            .init(productIdentifier: LocalProduct.fullVersion.rawValue, cancellationDate: Date(), originalPurchaseDate: nil)
        ])
        XCTAssertTrue(sut.isEligible(forFeature: .fullVersion))

        sut.reloadReceipt()
        XCTAssertFalse(sut.isEligible(forFeature: .fullVersion))
    }
}
