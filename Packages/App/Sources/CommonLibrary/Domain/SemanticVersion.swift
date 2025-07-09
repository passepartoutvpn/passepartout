//
//  SemanticVersion.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/8/25.
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

public struct SemanticVersion: Hashable, Sendable {
    public let major: Int

    public let minor: Int

    public let patch: Int

    public init?(_ string: String) {
        let tokens = string
            .components(separatedBy: ".")
            .compactMap(Int.init)
        guard tokens.count == 3 else {
            return nil
        }
        major = tokens[0]
        minor = tokens[1]
        patch = tokens[2]
    }
}

extension SemanticVersion: Comparable {
    private var value: Int {
        assert(major <= 0xff)
        assert(minor <= 0xff)
        assert(patch <= 0xff)
        return ((major & 0xff) << 16) + ((minor & 0xff) << 8) + patch
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

extension SemanticVersion: CustomStringConvertible {
    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}
