//
//  AppToolbar.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/7/24.
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

import AppLibrary
import PassepartoutKit
import SwiftUI

struct AppToolbar: ToolbarContent {

    @Environment(\.horizontalSizeClass)
    private var hsClass

    @Environment(\.verticalSizeClass)
    private var vsClass

    let profileManager: ProfileManager

    @Binding
    var layout: ProfilesLayout

    @Binding
    var isImporting: Bool

    let onSettings: () -> Void

    let onNewProfile: (Profile) -> Void

    var body: some ToolbarContent {
        if hsClass == .regular && vsClass == .regular {
            ToolbarItemGroup {
                addProfileMenu
                settingsButton
                layoutPicker
            }
        } else {
            ToolbarItem(placement: .navigation) {
                settingsButton
            }
            ToolbarItemGroup(placement: .primaryAction) {
                addProfileMenu
                layoutPicker
            }
        }
    }
}

private extension AppToolbar {
    var addProfileMenu: some View {
        AddProfileMenu(
            profileManager: profileManager,
            isImporting: $isImporting,
            onNewProfile: onNewProfile
        )
    }

    var settingsButton: some View {
        Button(action: onSettings) {
            ThemeImage(.advanced)
        }
    }

    var layoutPicker: some View {
        ProfilesLayoutPicker(layout: $layout)
    }
}

#Preview {
    NavigationStack {
        Text("AppToolbar")
            .toolbar {
                AppToolbar(
                    profileManager: .mock,
                    layout: .constant(.list),
                    isImporting: .constant(false),
                    onSettings: {},
                    onNewProfile: { _ in}
                )
            }
            .frame(width: 600, height: 400)
    }
    .environmentObject(Theme())
}
