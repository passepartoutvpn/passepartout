//
//  Theme+iOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/19/24.
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

#if os(iOS)

import SwiftUI

extension Theme {
    public convenience init() {
        self.init(dummy: ())
        animationCategories = [.diagnostics, .modules, .profiles, .providers]
    }
}

// MARK: - Modifiers

extension ThemeWindowModifier {
    func body(content: Content) -> some View {
        content
    }
}

extension ThemeNavigationDetailModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension ThemePlainButtonModifier {
    func body(content: Content) -> some View {
        Button(action: action) {
            content
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
        }
        .foregroundStyle(.primary)
    }
}

extension ThemeManualInputModifier {
    func body(content: Content) -> some View {
        content
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
}

extension ThemeSectionWithHeaderFooterModifier {
    func body(content: Content) -> some View {
        Section {
            content
        } header: {
            header.map(Text.init)
        } footer: {
            footer.map(Text.init)
        }
    }
}

// MARK: - Views

extension ThemeTappableText {
    var body: some View {
        commonView
            .foregroundStyle(.primary)
    }
}

extension ThemeTextField {
    var body: some View {
        commonView
    }
}

extension ThemeSecureField {
    var body: some View {
        commonView
    }
}

extension ThemeRemovableItemRow {
    func removeView() -> some View {
        EmptyView()
    }
}

extension ThemeEditableListSection.RemoveLabel {
    var body: some View {
        EmptyView()
    }
}

extension ThemeEditableListSection.EditLabel {
    var body: some View {
        EmptyView()
    }
}

#endif
