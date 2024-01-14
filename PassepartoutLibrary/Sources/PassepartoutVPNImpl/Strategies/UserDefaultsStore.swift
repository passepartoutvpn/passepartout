//
//  UserDefaultsStore.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/15/22.
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

import Foundation
import PassepartoutCore

public class UserDefaultsStore: KeyValueStore {
    private let defaults: UserDefaults

    private let key: (any KeyStoreLocation) -> String

    public init(defaults: UserDefaults, key: @escaping (any KeyStoreLocation) -> String) {
        self.defaults = defaults
        self.key = key
    }

    public func setValue<L, V>(_ value: V?, forLocation location: L) where L: KeyStoreLocation {
        guard let value = value else {
            defaults.removeObject(forKey: key(location))
            return
        }
        defaults.set(value, forKey: key(location))
    }

    public func value<L, V>(forLocation location: L) -> V? where L: KeyStoreLocation {
        defaults.object(forKey: key(location)) as? V
    }

    public func removeValue<L>(forLocation location: L) where L: KeyStoreLocation {
        defaults.removeObject(forKey: key(location))
    }
}
