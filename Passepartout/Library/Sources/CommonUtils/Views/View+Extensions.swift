//
//  View+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/18/22.
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

import SwiftUI

extension View {
    public func debugChanges(condition: Bool = false) {
        if condition {
            Self._printChanges()
        }
    }

    public func setLater<T>(_ value: T?, millis: Int = 50, block: @escaping (T?) -> Void) {
        globalSetLater(value, millis: millis, block: block)
    }

    @ViewBuilder
    public func `if`(_ condition: Bool) -> some View {
        if condition {
            self
        }
    }

    public func opaque(_ condition: Bool) -> some View {
        opacity(condition ? 1.0 : 0.0)
    }

    // https://www.avanderlee.com/swiftui/disable-animations-transactions/
    public func unanimated() -> some View {
        transaction {
            $0.animation = nil
        }
    }

    public func resized(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        GeometryReader { geo in
            self
                .frame(
                    width: width.map {
                        $0 * geo.size.width
                    },
                    height: height.map {
                        $0 * geo.size.height
                    }
                )
        }
    }
}

extension ViewModifier {
    public func debugChanges(condition: Bool = false) {
        if condition {
            Self._printChanges()
        }
    }

    public func setLater<T>(_ value: T?, millis: Int = 50, block: @escaping (T?) -> Void) {
        globalSetLater(value, millis: millis, block: block)
    }
}

private func globalSetLater<T>(_ value: T?, millis: Int = 50, block: @escaping (T?) -> Void) {
    Task {
        block(nil)
        try await Task.sleep(for: .milliseconds(millis))
        block(value)
    }
}

#if !os(tvOS)
extension Table {

    @ViewBuilder
    public func withoutColumnHeaders() -> some View {
        if #available(iOS 17, macOS 14, *) {
            tableColumnHeaders(.hidden)
        } else {
            self
        }
    }
}
#endif
