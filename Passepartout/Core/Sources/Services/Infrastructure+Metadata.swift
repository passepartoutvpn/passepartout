//
//  Infrastructure+Metadata.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/24/19.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

extension Infrastructure {
    public struct Metadata: Codable, Hashable, Comparable, CustomStringConvertible {
        public let name: Name
        
        public let inApp: String?
        
        // MARK: CustomStringConvertible

        public let description: String

        // MARK: Hashable
        
        public func hash(into hasher: inout Hasher) {
            name.hash(into: &hasher)
        }
        
        public static func ==(lhs: Infrastructure.Metadata, rhs: Infrastructure.Metadata) -> Bool {
            return lhs.name == rhs.name
        }

        // MARK: Comparable

        public static func <(lhs: Infrastructure.Metadata, rhs: Infrastructure.Metadata) -> Bool {
            return lhs.name < rhs.name
        }
    }
}
