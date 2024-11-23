//
//  AddProfileMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/24.
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

import CommonLibrary
import PassepartoutKit
import SwiftUI

struct AddProfileMenu: View {
    let profileManager: ProfileManager

    @Binding
    var isImporting: Bool

    let onMigrateProfiles: () -> Void

    let onNewProfile: (Profile) -> Void

    var body: some View {
        Menu {
            newProfileButton
            importProfileButton
            Divider()
            migrateProfilesButton
        } label: {
            ThemeImage(.add)
        }
    }
}

private extension AddProfileMenu {
    var newProfileButton: some View {
        Button {
            let profile = profileManager.new(withName: Strings.Placeholders.Profile.name)
            onNewProfile(profile)
        } label: {
            ThemeImageLabel(Strings.Views.App.Toolbar.newProfile, .profileEdit)
        }
    }

    var importProfileButton: some View {
        Button {
            isImporting = true
        } label: {
            ThemeImageLabel(Strings.Views.App.Toolbar.importProfile.withTrailingDots, .profileImport)
        }
    }

    var migrateProfilesButton: some View {
        Button(action: onMigrateProfiles) {
            ThemeImageLabel(Strings.Views.App.Toolbar.migrateProfiles.withTrailingDots, .profileMigrate)
        }
    }
}
