//
//  Blacklist.swift
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
public final class Blacklist<T>: ObservableObject where T: Equatable {
    private let isAllowed: (T) -> Bool

    private let allow: (T) -> Void

    private let deny: (T) -> Void

    public init(
        isAllowed: @escaping (T) -> Bool,
        allow: @escaping (T) -> Void,
        deny: @escaping (T) -> Void
    ) {
        self.isAllowed = isAllowed
        self.allow = allow
        self.deny = deny
    }

    public func isAllowed(_ value: T) -> Bool {
        isAllowed(value)
    }

    public func allow(_ value: T) {
        objectWillChange.send()
        allow(value)
    }

    public func deny(_ value: T) {
        objectWillChange.send()
        deny(value)
    }
}
