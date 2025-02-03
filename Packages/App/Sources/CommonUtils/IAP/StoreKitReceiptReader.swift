//
//  StoreKitReceiptReader.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/5/24.
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

import Foundation
import StoreKit

public final class StoreKitReceiptReader: InAppReceiptReader, Sendable {
    private let logger: LoggerProtocol

    public init(logger: LoggerProtocol) {
        self.logger = logger
    }

    public func receipt() async -> InAppReceipt? {
        var startDate: Date
        var elapsed: TimeInterval

        startDate = Date()
        logger.debug("Start fetching original build number...")
        let originalBuildNumber: Int?
        do {
            switch try await AppTransaction.shared {
            case .verified(let tx):
                originalBuildNumber = Int(tx.originalAppVersion)
            default:
                originalBuildNumber = nil
            }
        } catch {
            originalBuildNumber = nil
        }
        elapsed = -startDate.timeIntervalSinceNow
        logger.debug("Fetched original build number: \(elapsed)")

        startDate = Date()
        logger.debug("Start fetching transactions...")
        var transactions: [Transaction] = []
        for await entitlement in Transaction.currentEntitlements {
            switch entitlement {
            case .verified(let tx):
                transactions.append(tx)
            default:
                break
            }
        }
        elapsed = -startDate.timeIntervalSinceNow
        logger.debug("Fetched transactions: \(elapsed)")

        let purchaseReceipts = transactions
            .compactMap {
                InAppReceipt.PurchaseReceipt(
                    productIdentifier: $0.productID,
                    expirationDate: $0.expirationDate,
                    cancellationDate: $0.revocationDate,
                    originalPurchaseDate: $0.originalPurchaseDate
                )
            }

        return InAppReceipt(originalBuildNumber: originalBuildNumber, purchaseReceipts: purchaseReceipts)
    }
}
