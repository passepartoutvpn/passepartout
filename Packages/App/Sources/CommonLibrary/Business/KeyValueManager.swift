//
//  KeyValueManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/1/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

@MainActor
public final class KeyValueManager: ObservableObject {
    private var store: KeyValueStore

    private let fallback: [String: Any]

    public init(store: KeyValueStore = InMemoryStore(), fallback: [String: Any] = [:]) {
        self.store = store
        self.fallback = fallback
    }

    public func contains(_ key: String) -> Bool {
        store.value(for: key) != nil
    }

    public func object<T>(forKey key: String) -> T? {
        store.value(for: key) ?? fallback[key] as? T
    }

    public func set<T>(_ value: T?, forKey key: String) {
        store.set(value, for: key)
    }

    public func removeObject(forKey key: String) {
        store.removeValue(for: key)
    }

    public subscript<T>(_ key: String) -> T? {
        get {
            object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }
}

extension KeyValueManager {
    public struct InMemoryStore: KeyValueStore {
        private var map: [String: Any]

        public init() {
            map = [:]
        }

        public func value<V>(for key: String) -> V? {
            map[key] as? V
        }

        public mutating func set<V>(_ value: V, for key: String) {
            map[key] = value
        }

        public mutating func removeValue(for key: String) {
            map.removeValue(forKey: key)
        }
    }
}

// MARK: - Shortcuts

extension KeyValueManager {
    public func bool(forKey key: String) -> Bool {
        var value = self[key] as Bool?
        if value == nil {
            value = fallback[key] as? Bool
        }
        return value ?? false
    }

    public func integer(forKey key: String) -> Int {
        var value = self[key] as Int?
        if value == nil {
            value = fallback[key] as? Int
        }
        return value ?? 0
    }

    public func double(forKey key: String) -> Double {
        var value = self[key] as Double?
        if value == nil {
            value = fallback[key] as? Double
        }
        return value ?? 0.0
    }

    public func string(forKey key: String) -> String? {
        var value = self[key] as String?
        if value == nil {
            value = fallback[key] as? String
        }
        return value
    }
}
