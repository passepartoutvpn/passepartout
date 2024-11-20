//
//  AppProduct.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/11/19.
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

public struct AppProduct: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init?(rawValue: String) {
        if let range = rawValue.range(of: Self.featurePrefix) ?? rawValue.range(of: Self.providerPrefix) ?? rawValue.range(of: Self.donationPrefix) {
            self.rawValue = String(rawValue[range.lowerBound..<rawValue.endIndex])
        } else {
            self.rawValue = rawValue
        }
    }
}

extension AppProduct {
    public static var all: [Self] {
        Features.all + Full.all + Donations.all
    }

    var isLegacyPlatformVersion: Bool {
        switch self {
        case .Full.iOS, .Full.macOS:
            return true

        default:
            return false
        }
    }
}

extension AppProduct: CustomDebugStringConvertible {
    public var debugDescription: String {
        rawValue
    }
}
