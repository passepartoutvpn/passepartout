//
//  WSProviderServer.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/18.
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

public struct WSProviderServer: Codable {
    enum CodingKeys: String, CodingKey {
        case id

        case countryCode = "country"

        case extraCountryCodes = "extra_countries"

        case area

        case serverIndex = "num"

        case tags

        case hostname

        case numericAddresses = "addrs"
    }

    public let id: String

    public let countryCode: String

    public var extraCountryCodes: [String]?

    public var area: String?

    public var serverIndex: Int?

    public var tags: [String]?

//    public var geo: (Double, Double)?

    public var hostname: String?

    public var numericAddresses: Set<UInt32>?

    public init(id: String, countryCode: String) {
        self.id = id
        self.countryCode = countryCode
    }
}
