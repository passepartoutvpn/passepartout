//
//  PinActiveProfileToggle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/10/25.
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

#if !os(tvOS)

public struct PinActiveProfileToggle: View {

    @AppStorage(UIPreference.pinsActiveProfile.key)
    private var pinsActiveProfile = true

    public init() {
    }

    public var body: some View {
        Toggle(Strings.Views.Preferences.pinsActiveProfile, isOn: $pinsActiveProfile.animation())
    }
}

public struct HideActiveProfileButton: View {

    @AppStorage(UIPreference.pinsActiveProfile.key)
    private var pinsActiveProfile = true

    public init() {
    }

    public var body: some View {
        Button {
            withAnimation {
                pinsActiveProfile = false
            }
        } label: {
            ThemeImageLabel(Strings.Global.Actions.hide, .hide)
        }
    }
}

public struct HideActiveProfileModifier: ViewModifier {
    public init() {
    }

    public func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing) {
                HideActiveProfileButton()
            }
    }
}

#endif
