//
//  GenericMap+Codable.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/27/23.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

extension GenericMap: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        let map = try jsonDecode(data)
        self.init(map: map)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try jsonEncode(map)
        try container.encode(data)
    }
}

extension GenericMap {
    public static func decode(_ data: Data) throws -> GenericMap {
        .init(map: try jsonDecode(data))
    }

    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let data = try JSONEncoder().encode(self)
        return try JSONDecoder().decode(type, from: data)
    }

    public func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }
}

private func jsonEncode(_ map: [String: Any]) throws -> Data {
    try JSONSerialization.data(withJSONObject: map)
}

private func jsonDecode(_ data: Data) throws -> [String: Any] {
    try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
}
