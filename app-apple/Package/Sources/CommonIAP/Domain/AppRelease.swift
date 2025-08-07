// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonUtils
import Foundation

public struct AppRelease: Sendable {
    private let name: String

    fileprivate let date: Date

    public init(_ name: String, on string: String) {
        guard let date = string.asISO8601Date else {
            fatalError("Unable to parse ISO date for \(name)")
        }
        self.name = name
        self.date = date
    }
}

extension OriginalPurchase {
    public func isBefore(_ release: AppRelease) -> Bool {
        purchaseDate < release.date
    }
}
