//
//  Theme+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/31/24.
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

#if os(macOS)

import SwiftUI

extension Theme {
    public convenience init() {
        self.init(dummy: Void())
        animationCategories = [.diagnostics, .profiles, .providers]
    }
}

// MARK: - Shortcuts

extension View {
    public func themeLockScreen() -> some View {
        self
    }
}

// MARK: - Modifiers

extension ThemeWindowModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: size.width, height: size.height)
    }
}

extension ThemeManualInputModifier {
    func body(content: Content) -> some View {
        content
            .autocorrectionDisabled()
    }
}

extension ThemeContainerModifier {
    func body(content: Content) -> some View {
        Section {
            content
            footer.map {
                Text($0)
                    .themeSubtitle()
            }
        } header: {
            header.map(Text.init)
        }
    }
}

extension ThemeContainerEntryModifier {
    func body(content: Content) -> some View {
        VStack {
            if !isAction {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            subtitle.map {
                Text($0)
                    .themeSubtitle()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if isAction {
                HStack {
                    Spacer()
                    content
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Views

extension ThemeTappableText {
    public var body: some View {
        commonView
            .buttonStyle(.plain)
            .cursor(.hand)
    }
}

extension ThemeTextField {
    public var body: some View {
        fieldView
    }
}

extension ThemeSecureField {
    public var body: some View {
        fieldView
    }
}

extension ThemeRemovableItemRow {
    func removeView() -> some View {
        Button(action: removeAction) {
            ThemeImage(.contextRemove)
        }
        .buttonStyle(.borderless)
    }
}

extension ThemeEditableListSection.RemoveLabel {
    public var body: some View {
        Button(action: action) {
            ThemeImage(.editableSectionRemove)
        }
        .buttonStyle(.borderless)
    }
}

extension ThemeEditableListSection.EditLabel {
    public var body: some View {
        ThemeImage(.editableSectionEdit)
    }
}

#endif
