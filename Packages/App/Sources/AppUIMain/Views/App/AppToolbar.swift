//
//  AppToolbar.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/7/24.
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

import CommonLibrary
import CommonUtils
import SwiftUI

struct AppToolbar: ToolbarContent, SizeClassProviding {

    @Environment(\.horizontalSizeClass)
    var hsClass

    @Environment(\.verticalSizeClass)
    var vsClass

    let profileManager: ProfileManager

    let registry: Registry

    @Binding
    var layout: ProfilesLayout

    @Binding
    var isImporting: Bool

    let onSettings: () -> Void

    let onMigrateProfiles: () -> Void

    let onNewProfile: (EditableProfile) -> Void

    var body: some ToolbarContent {
        if isBigDevice {
            ToolbarItemGroup {
                addProfileMenu
                settingsButton
                layoutPicker
            }
        } else {
            ToolbarItem(placement: .navigation) {
                settingsButton
            }
            ToolbarItem(placement: .primaryAction) {
                addProfileMenu
            }
        }
    }
}

private extension AppToolbar {
    var addProfileMenu: some View {
        AddProfileMenu(
            profileManager: profileManager,
            registry: registry,
            isImporting: $isImporting,
            onMigrateProfiles: onMigrateProfiles,
            onNewProfile: onNewProfile
        )
    }

    var settingsButton: some View {
        Button(action: onSettings) {
            ThemeImage(.settings)
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
                    profileManager: .forPreviews,
                    registry: Registry(),
                    layout: .constant(.list),
                    isImporting: .constant(false),
                    onSettings: {},
                    onMigrateProfiles: {},
                    onNewProfile: { _ in }
                )
            }
            .frame(width: 600, height: 400)
    }
    .withMockEnvironment()
}
