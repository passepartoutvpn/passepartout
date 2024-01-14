//
//  StoreKitReceiptReader.swift
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
import PassepartoutLibrary

struct StoreKitReceiptReader: ReceiptReader {
    func receipt(for appType: AppType) -> InAppReceipt? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            pp_log.warning("No App Store receipt found!")
            return nil
        }

        let receipt = Receipt(contentsOfURL: url)

        let fallbackReceipt: Receipt? = {

            // in TestFlight, attempt fallback to existing release receipt
            if appType == .beta {
                guard let receipt else {
                    let releaseUrl = url.deletingLastPathComponent().appendingPathComponent("receipt")
                    guard releaseUrl != url else {
                        assertionFailure("How can release URL be equal to sandbox URL in TestFlight?")
                        return nil
                    }
                    pp_log.warning("Sandbox receipt not found, falling back to Release receipt")
                    return Receipt(contentsOfURL: releaseUrl)
                }
                return receipt
            }
            return receipt
        }()

        return fallbackReceipt?.asInAppReceipt
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
                    InAppReceipt.PurchaseReceipt(productIdentifier: $0.productIdentifier,
                                                 cancellationDate: $0.cancellationDate,
                                                 originalPurchaseDate: $0.originalPurchaseDate)
                }
        }
        return InAppReceipt(originalBuildNumber: originalBuildNumber,
                            purchaseReceipts: purchaseReceipts)
    }
}
