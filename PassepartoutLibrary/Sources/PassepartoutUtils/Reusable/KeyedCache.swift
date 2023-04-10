//
//  KeyedCache.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/17/22.
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

public class KeyedCache<K: Hashable, V> {
    private let query: String

    private var store: [K: V] = [:]

    public var isEmpty: Bool {
        store.isEmpty
    }

    public var storeValues: [V] {
        Array(store.values)
    }

    public init(_ query: String) {
        self.query = query
    }

    public func set(_ store: [K: V]) {
        self.store = store
    }

    public func put(_ key: K, value: V) {
        store[key] = value
    }

    public func put(_ key: K, valueBlock: (K) -> V?) -> V? {
        if let cachedValue = store[key] {
            return cachedValue
        }
        guard let value = valueBlock(key) else {
            return nil
        }
        store[key] = value
        pp_log.debug("Cache MISS [\(query)]")
        return value
    }

    public func forget(where condition: (K) -> Bool) {
        let removedKeys = store.keys.filter(condition)
        removedKeys.forEach {
            store.removeValue(forKey: $0)
        }
    }

    public func forget(_ key: K) {
        store.removeValue(forKey: key)
    }

    public func clear() {
        store.removeAll()
    }
}
