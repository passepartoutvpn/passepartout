//
//  KvittoReceiptReader.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/20/23.
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
import Kvitto

public final class KvittoReceiptReader: InAppReceiptReader, Sendable {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func receipt() -> InAppReceipt? {
        Receipt(contentsOfURL: url)?.asInAppReceipt
    }
}

private extension Receipt {
    var asInAppReceipt: InAppReceipt {
        var originalBuildNumber: Int?
        var purchaseReceipts: [InAppReceipt.PurchaseReceipt]?
        if let originalAppVersion, let buildNumber = Int(originalAppVersion) {
            originalBuildNumber = buildNumber
        }
        if let inAppPurchaseReceipts {
            purchaseReceipts = inAppPurchaseReceipts
                .map {
                    InAppReceipt.PurchaseReceipt(
                        productIdentifier: $0.productIdentifier,
                        expirationDate: $0.subscriptionExpirationDate,
                        cancellationDate: $0.cancellationDate,
                        originalPurchaseDate: $0.originalPurchaseDate
                    )
                }
        }
        return InAppReceipt(
            originalBuildNumber: originalBuildNumber,
            purchaseReceipts: purchaseReceipts
        )
    }
}
