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

import CommonUtils
import SwiftUI

extension Theme {
    public convenience init() {
        self.init(dummy: ())
        animationCategories = [.diagnostics, .modules, .profiles, .providers]
    }
}

// MARK: - Shortcuts

extension View {
    public func themePopover<Content>(
        isPresented: Binding<Bool>,
        size: ThemeModalSize = .medium,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(ThemeBooleanPopoverModifier(
            isPresented: isPresented,
            size: size,
            popover: content
        ))
    }

    public func themeLockScreen() -> some View {
        modifier(ThemeLockScreenModifier(lockedContent: LogoView.init))
    }
}

// MARK: - Presentation modifiers

struct ThemeBooleanPopoverModifier<Popover>: ViewModifier, SizeClassProviding where Popover: View {

    @EnvironmentObject
    private var theme: Theme

    @Environment(\.horizontalSizeClass)
    var hsClass

    @Environment(\.verticalSizeClass)
    var vsClass

    @Binding
    var isPresented: Bool

    let size: ThemeModalSize

    @ViewBuilder
    let popover: Popover

    func body(content: Content) -> some View {
        let modalSize = theme.modalSize(size)
        if isBigDevice {
            content
                .popover(isPresented: $isPresented) {
                    popover
                        .frame(minWidth: modalSize.width, minHeight: modalSize.height)
                        .themeLockScreen()
                }
        } else {
            content
                .sheet(isPresented: $isPresented) {
                    popover
                        .themeLockScreen()
                }
        }
    }
}

// MARK: - Content modifiers

extension ThemeWindowModifier {
    func body(content: Content) -> some View {
        content
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

extension ThemeRowWithFooterModifier {
    func body(content: Content) -> some View {
        content
        // omit footer on iOS/tvOS, use ThemeSectionWithHeaderFooterModifier
    }
}

// MARK: - Views

extension ThemeTappableText {
    public var body: some View {
        commonView
            .foregroundStyle(.primary)
    }
}

extension ThemeTextField {
    public var body: some View {
        labeledView
    }
}

extension ThemeSecureField {
    public var body: some View {
        labeledView
    }
}

extension ThemeRemovableItemRow {
    func removeView() -> some View {
        EmptyView()
    }
}

extension ThemeEditableListSection.RemoveLabel {
    public var body: some View {
        EmptyView()
    }
}

extension ThemeEditableListSection.EditLabel {
    public var body: some View {
        EmptyView()
    }
}

#endif
