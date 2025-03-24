//
//  ThemeDisclosableMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
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

#if !os(tvOS)

import SwiftUI

public struct ThemeDisclosableMenu<Content, Label>: View where Content: View, Label: View {

    @ViewBuilder
    private let content: () -> Content

    @ViewBuilder
    private let label: () -> Label

    public init(content: @escaping () -> Content, label: @escaping () -> Label) {
        self.content = content
        self.label = label
    }

    public var body: some View {
        Menu(content: content) {
            HStack(alignment: .firstTextBaseline) {
                label()
                ThemeImage(.disclose)
                    .foregroundStyle(.secondary)
            }
            .contentShape(.rect)
        }
        .foregroundStyle(.primary)
#if os(macOS)
        .buttonStyle(.plain)
#endif
        .cursor(.hand)
    }
}

#endif
