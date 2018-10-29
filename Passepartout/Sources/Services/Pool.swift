//
//  Pool.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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

struct Pool: Codable, Comparable, CustomStringConvertible {
    enum CodingKeys: String, CodingKey {
        case id

        case name

        case country
        
//        case location
        
        case hostname
        
        case numericAddresses = "addrs"
    }
    
    let id: String
    
    let name: String

    let country: String
    
//    let location: (Double, Double)
    
    let hostname: String
    
    let numericAddresses: [UInt32]
    
    func hasAddress(_ address: String) -> Bool {
        guard let ipv4 = DNSResolver.ipv4(fromString: address) else {
            return false
        }
        return numericAddresses.contains(ipv4)
    }

    // XXX: inefficient, can't easily use lazy on struct
    func addresses(sorted: Bool) -> [String] {
        var addrs = (sorted ? numericAddresses.sorted() : numericAddresses).map {
            return DNSResolver.string(fromIPv4: $0.bigEndian)
        }
        addrs.insert(hostname, at: 0)
        return addrs
    }

    // MARK: Comparable
    
    static func <(lhs: Pool, rhs: Pool) -> Bool {
        return lhs.name < rhs.name
    }

    // MARK: CustomStringConvertible
    
    var description: String {
        return "{[\(id)] \"\(name)\"}"
    }
}
