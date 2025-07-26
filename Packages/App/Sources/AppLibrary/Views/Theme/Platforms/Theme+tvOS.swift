// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

#if os(tvOS)

import SwiftUI

extension Theme {
    public convenience init() {
        self.init(dummy: Void())
        relevantWeight = .bold
        secondaryWeight = .light
    }

    public var primaryGradient: AnyGradient {
        darkAccentColor
            .opacity(0.6)
            .gradient
    }
}

// MARK: - Shortcuts

extension View {
    public func themeLockScreen() -> some View {
        self
    }
}

// MARK: - Modifiers

extension ThemeManualInputModifier {
    func body(content: Content) -> some View {
        content
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
}

extension ThemeContainerModifier {
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

extension ThemeContainerEntryModifier {
    func body(content: Content) -> some View {
        Section {
            content
        } header: {
            header.map(Text.init)
        } footer: {
            subtitle.map(Text.init)
        }
    }
}

// MARK: - Views

extension ThemeTextField {
    public var body: some View {
        TextField(title ?? "", text: $text)
    }
}

extension ThemeSecureField {
    public var body: some View {
        SecureField(title ?? "", text: $text)
    }
}

#endif
