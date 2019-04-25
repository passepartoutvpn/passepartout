//
//  Pool.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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
import TunnelKit

public struct Pool: Codable, Hashable {
    public enum CodingKeys: String, CodingKey {
        case id

        case country

        case area

        case num
        
        case tags
        
//        case location
        
        case hostname
        
        case numericAddresses = "addrs"
    }
    
    public let id: String
    
    public let country: String

    public let area: String?

    public let num: Int?
    
    public let tags: [String]?
    
//    public let location: (Double, Double)
    
    public let hostname: String?
    
    public let numericAddresses: [UInt32]?
    
    public func hasAddress(_ address: String) -> Bool {
        guard let numericAddresses = numericAddresses else {
            return false
        }
        guard let ipv4 = DNSResolver.ipv4(fromString: address) else {
            return false
        }
        return numericAddresses.contains(ipv4)
    }

    // XXX: inefficient, can't easily use lazy on struct
    public func addresses() -> [String] {
        var addrs = numericAddresses?.map { DNSResolver.string(fromIPv4: $0) } ?? []
        if let hostname = hostname {
            addrs.insert(hostname, at: 0)
        }
        return addrs
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

extension Pool {
    private static let localizedFormat = "%@ - %@"

    public var localizedCountry: String {
        return Utils.localizedCountry(country)
    }

    public var localizedId: String {
        let countryString = localizedCountry
        let zone: String
        if let area = area, let num = num {
            zone = "\(area) #\(num)"
        } else if let area = area {
            zone = area
        } else if let num = num {
            zone = "#\(num)"
        } else {
            return countryString
        }
        return String.init(format: Pool.localizedFormat, countryString, zone.uppercased())
    }

    public var areaId: String? {
        let id: String
        if let area = area, let num = num {
            id = "\(area) #\(num)"
        } else if let area = area {
            id = area
        } else if let num = num {
            id = "#\(num)"
        } else {
            return nil
        }
        return id.uppercased()
    }
}
