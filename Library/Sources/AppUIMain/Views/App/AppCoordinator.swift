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

import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI
import UILibrary

public struct AppCoordinator: View, AppCoordinatorConforming, SizeClassProviding {

    @Environment(\.isUITesting)
    private var isUITesting

    @Environment(\.horizontalSizeClass)
    public var hsClass

    @Environment(\.verticalSizeClass)
    public var vsClass

    @AppStorage(UIPreference.profilesLayout.key)
    private var layout: ProfilesLayout = .list

    private let profileManager: ProfileManager

    private let tunnel: ExtendedTunnel

    private let registry: Registry

    @State
    private var isImporting = false

    @State
    private var paywallReason: PaywallReason?

    @State
    private var modalRoute: ModalRoute?

    @State
    private var profilePath = NavigationPath()

    @State
    private var migrationPath = NavigationPath()

    @StateObject
    private var profileEditor = ProfileEditor()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    public init(
        profileManager: ProfileManager,
        tunnel: ExtendedTunnel,
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
        .modifier(OnboardingModifier(modalRoute: $modalRoute))
        .modifier(PaywallModifier(reason: $paywallReason))
        .themeModal(
            item: $modalRoute,
            options: {
                var options = ThemeModalOptions()
                options.size = modalRoute?.size ?? .large
                options.isFixedWidth = modalRoute?.isFixedWidth ?? false
                options.isFixedHeight = modalRoute?.isFixedHeight ?? false
                options.isInteractive = modalRoute?.isInteractive ?? true
                return options
            }(),
            content: modalDestination
        )
    }
}

// MARK: - Destinations

extension AppCoordinator {
    enum ModalRoute: Identifiable, Equatable {
        case about

        case editProfile(UUID?)

        case editProviderEntity(Profile, Module, SerializedProvider)

        case migrateProfiles

        case preferences

        var id: Int {
            switch self {
            case .about: return 1
            case .editProfile: return 2
            case .editProviderEntity: return 3
            case .migrateProfiles: return 4
            case .preferences: return 5
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }

        var size: ThemeModalSize {
            switch self {
            case .migrateProfiles:
                return .custom(width: 700, height: 400)

            default:
                return .large
            }
        }

        var isFixedWidth: Bool {
            switch self {
            case .migrateProfiles:
                return true

            default:
                return false
            }
        }

        var isFixedHeight: Bool {
            switch self {
            case .migrateProfiles:
                return true

            default:
                return false
            }
        }

        var isInteractive: Bool {
            switch self {
            case .editProfile:
                return false

            default:
                return true
            }
        }
    }

    var contentView: some View {
        ProfileContainerView(
            layout: overriddenLayout,
            profileManager: profileManager,
            tunnel: tunnel,
            registry: registry,
            isImporting: $isImporting,
            errorHandler: errorHandler,
            flow: .init(
                onEditProfile: {
                    guard let profile = profileManager.profile(withId: $0.id) else {
                        return
                    }
                    enterDetail(of: profile.editable(), initialModuleId: nil)
                },
                onMigrateProfiles: {
                    modalRoute = .migrateProfiles
                },
                onProviderEntityRequired: {
                    guard let pair = $0.selectedProvider else {
                        return
                    }
                    present(.editProviderEntity($0, pair.module, pair.selection))
                },
                onPurchaseRequired: {
                    // FIXME: #951, use of setLater/enableLater
                    setLater(.init($0, needsConfirmation: true)) {
                        paywallReason = $0
                    }
                }
            )
        )
    }

    func toolbarContent() -> some ToolbarContent {
        AppToolbar(
            profileManager: profileManager,
            registry: registry,
            layout: $layout,
            isImporting: $isImporting,
            onPreferences: {
                present(.preferences)
            },
            onAbout: {
                present(.about)
            },
            onMigrateProfiles: {
                present(.migrateProfiles)
            },
            onNewProfile: enterDetail
        )
    }

    @ViewBuilder
    func modalDestination(for item: ModalRoute?) -> some View {
        switch item {
        case .about:
            AboutCoordinator(
                profileManager: profileManager,
                tunnel: tunnel
            )

        case .editProfile(let initialModuleId):
            ProfileCoordinator(
                profileManager: profileManager,
                profileEditor: profileEditor,
                initialModuleId: initialModuleId,
                registry: registry,
                moduleViewFactory: DefaultModuleViewFactory(registry: registry),
                path: $profilePath,
                onDismiss: onDismiss
            )

        case .editProviderEntity(let profile, let module, let provider):
            ProviderEntitySelector(
                profileManager: profileManager,
                tunnel: tunnel,
                profile: profile,
                module: module,
                provider: provider,
                errorHandler: errorHandler
            )

        case .migrateProfiles:
            MigrateView(
                style: migrateViewStyle,
                profileManager: profileManager
            )
            .themeNavigationStack(closable: true, path: $migrationPath)

        case .preferences:
            PreferencesView(profileManager: profileManager)

        default:
            EmptyView()
        }
    }

    var overriddenLayout: ProfilesLayout {
        if isUITesting {
            return isBigDevice ? .grid : .list
        }
        return layout
    }

    var migrateViewStyle: MigrateView.Style {
#if os(iOS)
        .list
#else
        .table
#endif
    }

    func enterDetail(of profile: EditableProfile, initialModuleId: UUID?) {
        profilePath = NavigationPath()
        let isShared = profileManager.isRemotelyShared(profileWithId: profile.id)
        profileEditor.editProfile(profile, isShared: isShared)
        present(.editProfile(initialModuleId))
    }

    func onDismiss() {
        present(nil)
    }

    func present(_ route: ModalRoute?) {

        // FIXME: #951, use of setLater/enableLater
        setLater(route) {
            modalRoute = $0
        }
    }
}

#Preview {
    AppCoordinator(
        profileManager: .forPreviews,
        tunnel: .forPreviews,
        registry: Registry()
    )
    .withMockEnvironment()
}
