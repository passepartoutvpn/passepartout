//
//  AppInlineCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/13/24.
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
import UtilsLibrary

@MainActor
struct AppInlineCoordinator: View {

    @Binding
    var layout: ProfilesLayout

    let profileManager: ProfileManager

    let profileEditor: ProfileEditor

    let tunnel: Tunnel

    let registry: Registry

    @State
    private var path = NavigationPath()

    @State
    private var modalRoute: ModalRoute?

    @State
    private var isImporting = false

    var body: some View {
        NavigationStack(path: $path) {
            contentView
                .toolbar(content: toolbarContent)
                .navigationDestination(for: NavigationRoute.self, destination: pushDestination)
        }
        .themeModal(item: $modalRoute, isRoot: true, content: modalDestination)
    }
}

// MARK: - Destinations

private extension AppInlineCoordinator {
    enum NavigationRoute: Hashable {
        case editProfile
    }

    enum ModalRoute: Identifiable {
        case editProviderEntity(Profile, Module, ModuleMetadata.Provider)

        case settings

        case about

        var id: Int {
            switch self {
            case .editProviderEntity: return 1
            case .settings: return 2
            case .about: return 3
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
    func pushDestination(for item: NavigationRoute) -> some View {
        switch item {
        case .editProfile:
            ProfileCoordinator(
                profileManager: profileManager,
                profileEditor: profileEditor,
                moduleViewFactory: DefaultModuleViewFactory(),
                modally: false,
                path: $path
            ) {
                path.removeLast()
            }
        }
    }

    @ViewBuilder
    func modalDestination(for item: ModalRoute?) -> some View {
        switch item {
        case .editProviderEntity(let profile, let module, let provider):
            ProviderEntitySelector(
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
        profileEditor.editProfile(
            profile,
            isShared: profileManager.isRemotelyShared(profileWithId: profile.id)
        )
        push(.editProfile)
    }

    func push(_ item: NavigationRoute) {
        path.append(item)
    }
}

#Preview {

    @State
    var layout: ProfilesLayout = .list

    return AppInlineCoordinator(
        layout: $layout,
        profileManager: .mock,
        profileEditor: ProfileEditor(profile: .mock),
        tunnel: .mock,
        registry: Registry()
    )
    .withMockEnvironment()
}
