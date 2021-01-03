//
//  Pool.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/18.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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

public class Pool: Codable, Hashable {
    public enum CodingKeys: String, CodingKey {
        case id

        case country
        
        case extraCountries = "extra_countries"

        case area

        case num
        
        case tags
        
//        case location
        
        case hostname
        
        case isResolved = "resolved"

        case numericAddresses = "addrs"
    }
    
    public let id: String
    
    public let country: String
    
    public let extraCountries: [String]?

    public let area: String?

    public let num: Int?
    
    public let tags: [String]?
    
//    public let location: (Double, Double)
    
    public let hostname: String?

    public let isResolved: Bool?
    
    public let numericAddresses: [UInt32]?
    
    // XXX: inefficient but convenient field (not serialized)
    public func category(in infrastructure: Infrastructure) -> PoolCategory? {
        for category in infrastructure.categories {
            for group in category.groups {
                for pool in group.pools {
                    if pool.id == id {
                        return category
                    }
                }
            }
        }
        return nil
    }

    public func supportedPresetIds(in infrastructure: Infrastructure) -> [String] {
        let poolCategory = category(in: infrastructure)
        return poolCategory?.presets ?? infrastructure.presets.map { $0.id }
    }
    
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
    
    // MARK: Equatable

    public static func == (lhs: Pool, rhs: Pool) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

extension Pool {
    public var localizedCountry: String {
        return Utils.localizedCountry(country)
    }

    public var localizedId: String {
        var comps: [String] = [localizedCountry]
        if let secondaryId = optionalSecondaryId {
            comps.append(secondaryId)
        }
        return comps.joined(separator: " - ")
    }

    public var secondaryId: String {
        return optionalSecondaryId ?? ""
    }

    private var optionalSecondaryId: String? {
        var comps: [String] = []
        if let extraCountries = extraCountries {
            comps.append(contentsOf: extraCountries.map { Utils.localizedCountry($0) })
        }
        if let area = area {
//            comps.append(area.uppercased())
            comps.append(area.capitalized)
        }
        if let num = num {
            comps.append("#\(num)")
        }
        guard !comps.isEmpty else {
            return nil
        }
        var str = comps.joined(separator: " ")
        if let tags = tags {
            let suffix = tags.map { $0.uppercased() }.joined(separator: ",")
            str = "\(str) (\(suffix))"
        }
        return str
    }
}

public extension Array where Element: Pool {
    func sortedPools() -> [Element] {
        return sorted {
            guard let lnum = $0.num else {
                return true
            }
            guard let rnum = $1.num else {
                return false
            }
            guard lnum != rnum else {
                return $0.secondaryId < $1.secondaryId
            }
            return lnum < rnum
        }
    }
}
