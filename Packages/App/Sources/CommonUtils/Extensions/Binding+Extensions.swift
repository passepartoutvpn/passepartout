//
//  Binding+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
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

import SwiftUI

public func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
    Binding {
        lhs.wrappedValue ?? rhs
    } set: {
        lhs.wrappedValue = $0
    }
}

extension Binding where Value == Bool {
    public init<T: Equatable>(presenting other: Binding<T?>, equal value: T) {
        self.init {
            other.wrappedValue == value
        } set: {
            if !$0 {
                other.wrappedValue = nil
            }
        }
    }

    public init<T>(presenting other: Binding<T?>, if block: @escaping (T?) -> Bool) {
        self.init {
            block(other.wrappedValue)
        } set: {
            if !$0 {
                other.wrappedValue = nil
            }
        }
    }
}

extension Binding {
    public func toString() -> Binding<String> where Value == URL? {
        .init {
            wrappedValue?.absoluteString ?? ""
        } set: {
            wrappedValue = URL(string: $0) ?? wrappedValue
        }
    }

    public func toString(omittingZero: Bool = false) -> Binding<String> where Value: FixedWidthInteger {
        .init {
            if omittingZero, wrappedValue == .zero {
                return ""
            }
            return wrappedValue.description
        } set: {
            guard let v = Value($0) else {
                wrappedValue = .zero
                return
            }
            wrappedValue = v
        }
    }
}
