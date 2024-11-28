//
//  Theme+tvOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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

#if os(tvOS)

import SwiftUI

extension Theme {
    public convenience init() {
        self.init(dummy: Void())
        relevantWeight = .bold
        secondaryWeight = .light
    }

//    public var primaryGradient: AnyGradient {
//        primaryColor
//            .opacity(0.6)
//            .gradient
//    }
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
