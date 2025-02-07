//
//  NavigatingButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/7/25.
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

public struct NavigatingButton<Label>: View where Label: View {
    private let action: () -> Void

    private let label: () -> Label

    public init(action: @escaping () -> Void, label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                label()
                ThemeImage(.navigate)
            }
        }
        .buttonStyle(.plain)
    }
}

extension NavigatingButton where Label == Text {
    public init(_ title: String, action: @escaping () -> Void) {
        self.init(action: action) {
            Text(title)
        }
    }
}
