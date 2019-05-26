//
//  PoolGroup.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/19.
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

public struct PoolGroup: Codable, Hashable, Comparable, CustomStringConvertible {
    public let country: String
    
    public let area: String?
    
    public let pools: [Pool]
    
    private var id: String {
        var id = country
        if let area = area {
            id += area
        }
        return id
    }
    
    private var localizedId: String {
        var localizedId = Utils.localizedCountry(country)
        if let area = area {
            localizedId += area
        }
        return localizedId
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
    
    // MARK: Comparable
    
    public static func <(lhs: PoolGroup, rhs: PoolGroup) -> Bool {
        return lhs.localizedId < rhs.localizedId
    }
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        return "{\(country), \(area ?? "--")}"
    }
}

extension PoolGroup {
    public var localizedCountry: String {
        return Utils.localizedCountry(country)
    }
}
