//
//  ObservableList.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/8/24.
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

@MainActor
public final class ObservableList<T>: ObservableObject where T: Equatable {
    private let contains: (T) -> Bool

    private let add: (T) -> Void

    private let remove: (T) -> Void

    public init(
        contains: @escaping (T) -> Bool,
        add: @escaping (T) -> Void,
        remove: @escaping (T) -> Void
    ) {
        self.contains = contains
        self.add = add
        self.remove = remove
    }

    public func contains(_ value: T) -> Bool {
        contains(value)
    }

    public func add(_ value: T) {
        objectWillChange.send()
        add(value)
    }

    public func remove(_ value: T) {
        objectWillChange.send()
        remove(value)
    }
}
