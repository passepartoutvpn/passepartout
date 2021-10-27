//
//  PoolGroup.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/19.
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

public class PoolGroup: Codable, Hashable, Comparable, CustomStringConvertible {
    public let country: String
    
    public let pools: [Pool]
    
    private var id: String {
        return country
    }
    
    private var localizedId: String {
        return Utils.localizedCountry(country)
    }
    
    // MARK: Equatable
    
    public static func ==(lhs: PoolGroup, rhs: PoolGroup) -> Bool {
        return lhs.localizedId == rhs.localizedId
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
        return country
    }
}

extension PoolGroup {
    public var localizedCountry: String {
        return Utils.localizedCountry(country)
    }
}

extension PoolGroup {
    public func uniqueId(in category: PoolCategory) -> String {
        var components: [String] = []
        components.append(category.name)
        components.append(country)
        return components.joined(separator: "/")
    }
}
