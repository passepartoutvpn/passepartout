//
//  MockAppReceiptReader.swift
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

import CommonUtils
import Foundation

public actor MockAppReceiptReader: AppReceiptReader {
    private var localReceipt: InAppReceipt?

    public init(receipt localReceipt: InAppReceipt? = nil) {
        self.localReceipt = localReceipt
    }

    public func setReceipt(withBuild build: Int, products: Set<AppProduct>, cancelledProducts: Set<AppProduct> = []) {
        setReceipt(
            withBuild: build,
            identifiers: Set(products.map(\.rawValue)),
            cancelledIdentifiers: Set(cancelledProducts.map(\.rawValue))
        )
    }

    public func setReceipt(withBuild build: Int, identifiers: Set<String>, cancelledIdentifiers: Set<String> = []) {
        localReceipt = InAppReceipt(originalBuildNumber: build, purchaseReceipts: identifiers.map {
            .init(
                productIdentifier: $0,
                expirationDate: nil,
                cancellationDate: cancelledIdentifiers.contains($0) ? Date() : nil,
                originalPurchaseDate: nil
            )
        })
    }

    public func receipt(at userLevel: AppUserLevel) async -> InAppReceipt? {
        localReceipt
    }

    public func addPurchase(with identifier: String) {
        guard let localReceipt else {
            fatalError("Call setReceipt() first")
        }
        var purchaseReceipts = localReceipt.purchaseReceipts ?? []
        purchaseReceipts.append(.init(
            productIdentifier: identifier,
            expirationDate: nil,
            cancellationDate: nil,
            originalPurchaseDate: nil
        ))
        let newReceipt = InAppReceipt(
            originalBuildNumber: localReceipt.originalBuildNumber,
            purchaseReceipts: purchaseReceipts
        )
        self.localReceipt = newReceipt
    }
}
