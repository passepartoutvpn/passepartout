//
//  DataUnit.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/30/18.
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

public enum DataUnit: Int, CustomStringConvertible {
    case byte = 1
    
    case kilobyte = 1024
    
    case megabyte = 1048576
    
    case gigabyte = 1073741824

    fileprivate var showsDecimals: Bool {
        switch self {
        case .byte, .kilobyte:
            return false
            
        case .megabyte, .gigabyte:
            return true
        }
    }
    
    fileprivate var boundary: Int {
        return Int(0.1 * Double(rawValue))
    }

    // MARK: CustomStringConvertible
    
    public var description: String {
        switch self {
        case .byte:
            return "B"

        case .kilobyte:
            return "kB"

        case .megabyte:
            return "MB"

        case .gigabyte:
            return "GB"
        }
    }
}

public extension Int {
    private static let allUnits: [DataUnit] = [
        .gigabyte,
        .megabyte,
        .kilobyte,
        .byte
    ]
    
    var dataUnitDescription: String {
        if self == 0 {
            return "0B"
        }
        for u in Int.allUnits {
            if self >= u.boundary {
                if !u.showsDecimals {
                    return "\(self / u.rawValue)\(u)"
                }
                let count = Double(self) / Double(u.rawValue)
                return String(format: "%.2f%@", count, u.description)
            }
        }
        fatalError("Number is negative")
    }
}
