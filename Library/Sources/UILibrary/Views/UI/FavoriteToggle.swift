//
//  FavoriteToggle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/25/24.
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
import SwiftUI

public struct FavoriteToggle<ID>: View where ID: Hashable {
    private let value: ID

    @ObservedObject
    private var selection: ObservableList<ID>

    @State
    private var hover: ID?

    public init(value: ID, selection: ObservableList<ID>) {
        self.value = value
        self.selection = selection
    }

    public var body: some View {
        Button {
            if selection.contains(value) {
                selection.remove(value)
            } else {
                selection.add(value)
            }
        } label: {
            ThemeImage(selection.contains(value) ? .favoriteOn : .favoriteOff)
                .opaque(opaque)
        }
#if os(macOS)
        .onHover {
            hover = $0 ? value : nil
        }
#endif
    }
}

private extension FavoriteToggle {
    var opaque: Bool {
#if os(macOS)
        selection.contains(value) || value == hover
#else
        true
#endif
    }
}
