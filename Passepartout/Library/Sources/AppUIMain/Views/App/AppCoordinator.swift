//
//  AppCoordinator.swift
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
import CommonLibrary
import PassepartoutKit
import SwiftUI

public struct AppCoordinator: View {

    @AppStorage(AppPreference.profilesLayout.key)
    private var layout: ProfilesLayout = .list

    private let profileManager: ProfileManager

    private let tunnel: Tunnel

    private let registry: Registry

    @StateObject
    private var profileEditor = ProfileEditor()

    @State
    private var modalRoute: ModalRoute?

    @State
    private var isImporting = false

    @State
    private var profilePath = NavigationPath()

    public init(
        profileManager: ProfileManager,
        tunnel: Tunnel,
        registry: Registry
    ) {
        self.profileManager = profileManager
        self.tunnel = tunnel
        self.registry = registry
    }

    public var body: some View {
        NavigationStack {
            contentView
                .toolbar(content: toolbarContent)
        }
        .themeModal(item: $modalRoute, isRoot: true, isInteractive: false, content: modalDestination)
    }
}

// MARK: - Destinations

extension AppCoordinator {
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
                path: $profilePath,
                onDismiss: {
                    modalRoute = nil
                }
            )

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
        profilePath = NavigationPath()
        profileEditor.editProfile(
            profile,
            isShared: profileManager.isRemotelyShared(profileWithId: profile.id)
        )
        modalRoute = .editProfile
    }
}

#Preview {
    AppCoordinator(
        profileManager: .mock,
        tunnel: .mock,
        registry: Registry()
    )
    .withMockEnvironment()
}
