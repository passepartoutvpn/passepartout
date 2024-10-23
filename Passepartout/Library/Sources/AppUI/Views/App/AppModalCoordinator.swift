//
//  AppModalCoordinator.swift
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

import AppLibrary
import PassepartoutKit
import SwiftUI

@MainActor
struct AppModalCoordinator: View {

    @Binding
    var layout: ProfilesLayout

    let profileManager: ProfileManager

    let profileEditor: ProfileEditor

    let tunnel: Tunnel

    let registry: Registry

    @State
    private var modalRoute: ModalRoute?

    @State
    private var isImporting = false

    @State
    private var profilePath = NavigationPath()

    var body: some View {
        NavigationStack {
            contentView
                .toolbar(content: toolbarContent)
        }
        .themeModal(item: $modalRoute, isRoot: true, isInteractive: false, content: modalDestination)
    }
}

// MARK: - Destinations

extension AppModalCoordinator {
    enum ModalRoute: Identifiable {
        case editProfile

        case editProviderEntity(Profile, Module, ModuleMetadata.Provider)

        case settings

        case about

        var id: Int {
            switch self {
            case .editProfile: return 1
            case .editProviderEntity: return 2
            case .settings: return 3
            case .about: return 4
            }
        }
    }

    var contentView: some View {
        ProfileContainerView(
            layout: layout,
            profileManager: profileManager,
            tunnel: tunnel,
            registry: registry,
            isImporting: $isImporting,
            flow: .init(
                onEditProfile: {
                    guard let profile = profileManager.profile(withId: $0.id) else {
                        return
                    }
                    enterDetail(of: profile)
                },
                onEditProviderEntity: {
                    guard let pair = $0.firstProviderModuleWithMetadata else {
                        return
                    }
                    modalRoute = .editProviderEntity($0, pair.0, pair.1)
                }
            )
        )
    }

    func toolbarContent() -> some ToolbarContent {
        AppToolbar(
            profileManager: profileManager,
            layout: $layout,
            isImporting: $isImporting,
            onSettings: {
                modalRoute = .settings
            },
            onAbout: {
                modalRoute = .about
            },
            onNewProfile: enterDetail
        )
    }

    @ViewBuilder
    func modalDestination(for item: ModalRoute?) -> some View {
        switch item {
        case .editProfile:
            ProfileCoordinator(
                profileManager: profileManager,
                profileEditor: profileEditor,
                moduleViewFactory: DefaultModuleViewFactory(),
                modally: true,
                path: $profilePath
            ) {
                modalRoute = nil
            }

        case .editProviderEntity(let profile, let module, let provider):
            ProviderSelectorView(
                profileManager: profileManager,
                tunnel: tunnel,
                profile: profile,
                module: module,
                provider: provider
            )

        case .settings:
            SettingsView(profileManager: profileManager)

        case .about:
            AboutRouterView(
                profileManager: profileManager,
                tunnel: tunnel
            )

        default:
            EmptyView()
        }
    }

    func enterDetail(of profile: Profile) {
        profilePath = NavigationPath()
        profileEditor.editProfile(
            profile,
            isShared: profileManager.isRemotelyShared(profileWithId: profile.id)
        )
        modalRoute = .editProfile
    }
}

#Preview {

    @State
    var layout: ProfilesLayout = .grid

    return AppModalCoordinator(
        layout: $layout,
        profileManager: .mock,
        profileEditor: ProfileEditor(profile: .mock),
        tunnel: .mock,
        registry: Registry()
    )
    .withMockEnvironment()
}
