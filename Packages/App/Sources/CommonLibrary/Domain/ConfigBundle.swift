//
//  ConfigBundle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/20/25.
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

import GenericJSON

public struct ConfigBundle: Decodable {
    public struct Config: Codable {
        public let rate: Int

        public let data: JSON
    }

    // flag -> deployment (0-100)
    public let map: [ConfigFlag: Config]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        map = try container
            .decode([String: Config].self)
            .reduce(into: [:]) {
                guard let flag = ConfigFlag(rawValue: $1.key) else {
                    return
                }
                $0[flag] = $1.value
            }
    }

    public var activeFlags: Set<ConfigFlag> {
        Set(map.keys)
    }
}
