//
//  ProfileAttributes+ModulePreferences.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/9/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import CommonUtils
import Foundation
import GenericJSON
import PassepartoutKit

extension ProfileAttributes {
    public struct ModulePreferences {
        private enum Key: String {
            case excludedEndpoints
        }

        private(set) var userInfo: [String: AnyHashable]

        init(userInfo: [String: AnyHashable]?) {
            self.userInfo = userInfo ?? [:]
        }

        public var excludedEndpoints: Set<ExtendedEndpoint> {
            get {
                Set(rawExcludedEndpoints.compactMap(ExtendedEndpoint.init(rawValue:)))
            }
            set {
                rawExcludedEndpoints = newValue.map(\.rawValue)
            }
        }

        public func isExcludedEndpoint(_ endpoint: ExtendedEndpoint) -> Bool {
            rawExcludedEndpoints.contains(endpoint.rawValue)
        }

        public mutating func addExcludedEndpoint(_ endpoint: ExtendedEndpoint) {
            rawExcludedEndpoints.append(endpoint.rawValue)
        }

        public mutating func removeExcludedEndpoint(_ endpoint: ExtendedEndpoint) {
            let rawValue = endpoint.rawValue
            rawExcludedEndpoints.removeAll {
                $0 == rawValue
            }
        }
    }
}

extension ProfileAttributes.ModulePreferences {
    var rawExcludedEndpoints: [String] {
        get {
            userInfo[Key.excludedEndpoints.rawValue] as? [String] ?? []
        }
        set {
            userInfo[Key.excludedEndpoints.rawValue] = newValue
        }
    }
}
