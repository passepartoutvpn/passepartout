//
//  StoreKitReceiptReader.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/5/24.
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
import StoreKit

public final class StoreKitReceiptReader: InAppReceiptReader, Sendable {
    public init() {
    }

    public func receipt() async -> InAppReceipt? {
        var transactions: [Transaction] = []
        for await entitlement in Transaction.currentEntitlements {
            switch entitlement {
            case .verified(let tx):
                transactions.append(tx)

            default:
                break
            }
        }
        let purchaseReceipts = transactions
            .compactMap {
                InAppReceipt.PurchaseReceipt(
                    productIdentifier: $0.productID,
                    expirationDate: $0.expirationDate,
                    cancellationDate: $0.revocationDate,
                    originalPurchaseDate: $0.originalPurchaseDate
                )
            }

        return InAppReceipt(originalBuildNumber: nil, purchaseReceipts: purchaseReceipts)
    }
}
