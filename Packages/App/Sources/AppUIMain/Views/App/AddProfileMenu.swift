//
//  AddProfileMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/24.
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
import PassepartoutKit
import SwiftUI

struct AddProfileMenu: View {

    @EnvironmentObject
    private var apiManager: APIManager

    let profileManager: ProfileManager

    let registry: Registry

    @Binding
    var isImporting: Bool

    let onMigrateProfiles: () -> Void

    let onNewProfile: (EditableProfile) -> Void

    var body: some View {
        Menu {
            emptyProfileButton
            importProfileButton
            Divider()
            providerProfileMenu
            Divider()
            migrateProfilesButton
        } label: {
            ThemeImage(.add)
        }
    }
}

private extension AddProfileMenu {
    var emptyProfileButton: some View {
        Button {
            let editable = EditableProfile(name: newName)
            onNewProfile(editable)
        } label: {
            ThemeImageLabel(Strings.Views.App.Toolbar.NewProfile.empty, .profileEdit)
        }
    }

    var importProfileButton: some View {
        Button {
            isImporting = true
        } label: {
            ThemeImageLabel(Strings.Views.App.Toolbar.importProfile.forMenu, .profileImport)
        }
    }

    var providerProfileMenu: some View {
        Menu {
            ForEach(supportedProviders, content: providerSubmenu(for:))
        } label: {
            ThemeImageLabel(Strings.Views.App.Toolbar.NewProfile.provider, .profileProvider)
        }
    }

    func providerSubmenu(for provider: Provider) -> some View {
        ProviderSubmenu(
            provider: provider,
            registry: registry,
            onSelect: {
                var copy = $0
                copy.name = profileManager.firstUniqueName(from: copy.name)
                onNewProfile(copy)
            }
        )
    }

    var migrateProfilesButton: some View {
        Button(action: onMigrateProfiles) {
            ThemeImageLabel(Strings.Views.App.Toolbar.migrateProfiles.forMenu, .profileMigrate)
        }
    }
}

private extension AddProfileMenu {
    var newName: String {
        profileManager.firstUniqueName(from: Strings.Placeholders.Profile.name)
    }

    var supportedProviders: [Provider] {
        apiManager.providers
    }
}

// MARK: - Providers

private struct ProviderSubmenu: View {
    let provider: Provider

    let registry: Registry

    let onSelect: (EditableProfile) -> Void

    var body: some View {
        Menu {
            ForEach(Array(sortedTypes), id: \.self, content: profileButton(for:))
        } label: {
            Text(provider.description)
        }
    }

    func profileButton(for moduleType: ModuleType) -> some View {
        Button(moduleType.localizedDescription) {
            var editable = EditableProfile()
            editable.name = provider.description
            var moduleBuilder = ProviderModule.Builder()
            moduleBuilder.providerId = provider.id
            moduleBuilder.providerModuleType = moduleType
            editable.modules.append(moduleBuilder)
            var onDemandBuilder = OnDemandModule.Builder()
            onDemandBuilder.isEnabled = true
            editable.modules.append(onDemandBuilder)
            editable.activeModulesIds = Set(editable.modules.map(\.id))
            onSelect(editable)
        }
    }

    private var sortedTypes: [ModuleType] {
        provider.metadata.keys
            .sorted {
                $0.localizedDescription < $1.localizedDescription
            }
    }
}
