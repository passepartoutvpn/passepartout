//
//  AppRelease.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/7/25.
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
