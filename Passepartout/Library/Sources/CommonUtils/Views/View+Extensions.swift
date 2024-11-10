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
}

extension ViewModifier {
    public func debugChanges(condition: Bool = false) {
        if condition {
            Self._printChanges()
        }
    }
}
