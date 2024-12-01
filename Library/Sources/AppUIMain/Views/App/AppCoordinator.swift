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

    @EnvironmentObject
    private var iapManager: IAPManager

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
    private var interactiveManager = InteractiveManager()

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
            options: modalRoute?.options(),
            content: modalDestination
        )
        .onChange(of: interactiveManager.isPresented) {
            modalRoute = $0 ? .interactiveLogin : nil
        }
    }
}

// MARK: -

extension AppCoordinator {
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
                connectionFlow: .init(
                    onConnect: {
                        await onConnect($0, force: false)
                    },
                    onProviderEntityRequired: {
                        onProviderEntityRequired($0, force: false)
                    }
                )
            )
        )
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

        case .editProviderEntity(let profile, let force, let module, let provider):
            ProviderEntitySelector(
                module: module,
                provider: provider,
                errorHandler: errorHandler,
                onSelect: {
                    try await onSelectProviderEntity(
                        $0,
                        force: force,
                        module: module,
                        profile: profile
                    )
                }
            )

        case .interactiveLogin:
            InteractiveCoordinator(style: .modal, manager: interactiveManager) {
                errorHandler.handle(
                    $0,
                    title: interactiveManager.editor.profile.name,
                    message: Strings.Errors.App.tunnel
                )
            }
            .presentationDetents([.medium])

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
}

// MARK: - Handlers

private extension AppCoordinator {
    func onConnect(_ profile: Profile, force: Bool) async {
        do {
            try iapManager.verify(profile)
            try await tunnel.connect(with: profile, force: force)
        } catch AppError.ineligibleProfile(let requiredFeatures) {
            onPurchaseRequired(requiredFeatures)
        } catch AppError.interactiveLogin {
            onInteractiveLogin(profile) {
                await onConnect($0, force: true)
            }
        } catch let ppError as PassepartoutError {
            switch ppError.code {
            case .missingProviderEntity:
                onProviderEntityRequired(profile, force: force)
            default:
                onError(ppError, profile: profile)
            }
        } catch {
            onError(error, profile: profile)
        }
    }

    func onInteractiveLogin(_ profile: Profile, _ onComplete: @escaping InteractiveManager.CompletionBlock) {
        pp_log(.app, .notice, "Present interactive login")
        interactiveManager.present(with: profile, onComplete: onComplete)
    }

    func onPurchaseRequired(_ features: Set<AppFeature>) {
        setLater(.init(features, needsConfirmation: true)) {
            paywallReason = $0
        }
    }

    func onError(_ error: Error, profile: Profile) {
        errorHandler.handle(
            error,
            title: profile.name,
            message: Strings.Errors.App.tunnel
        )
    }
}

private extension AppCoordinator {
    func onProviderEntityRequired(_ profile: Profile, force: Bool) {
        guard let pair = profile.selectedProvider else {
            return
        }
        present(.editProviderEntity(profile, force, pair.module, pair.selection))
    }

    func onSelectProviderEntity(
        _ entity: any ProviderEntity & Encodable,
        force: Bool,
        module: Module,
        profile: Profile
    ) async throws {

        // XXX: select entity after dismissing
        try await Task.sleep(for: .milliseconds(500))

        pp_log(.app, .info, "Select new provider entity: \(entity)")
        do {
            // FIXME: ###, move stuff like this to some ProfileFactory
            guard var moduleBuilder = module.providerModuleBuilder() else {
                assertionFailure("Module is not a ProviderModuleBuilder?")
                return
            }
            try moduleBuilder.setProviderEntity(entity)
            let newModule = try moduleBuilder.tryBuild()

            var builder = profile.builder()
            builder.saveModule(newModule)
            let newProfile = try builder.tryBuild()

            let wasConnected = newProfile.id == tunnel.currentProfile?.id && tunnel.status == .active
            try await profileManager.save(newProfile, isLocal: true)
            if !wasConnected {
                pp_log(.app, .info, "Profile \(newProfile.id) was not connected, will connect to new provider entity")
                await onConnect(newProfile, force: force)
            } else {
                pp_log(.app, .info, "Profile \(newProfile.id) was connected, will reconnect to new provider entity via AppContext observation")
            }
        } catch {
            pp_log(.app, .error, "Unable to save new provider entity: \(error)")
            throw error
        }
    }

    func enterDetail(of profile: EditableProfile, initialModuleId: UUID?) {
        profilePath = NavigationPath()
        let isShared = profileManager.isRemotelyShared(profileWithId: profile.id)
        profileEditor.editProfile(profile, isShared: isShared)
        present(.editProfile(initialModuleId))
    }
}

private extension AppCoordinator {
    func present(_ route: ModalRoute?) {
        setLater(route) {
            modalRoute = $0
        }
    }

    func onDismiss() {
        present(nil)
    }
}

// MARK: - Previews

#Preview {
    AppCoordinator(
        profileManager: .forPreviews,
        tunnel: .forPreviews,
        registry: Registry()
    )
    .withMockEnvironment()
}
