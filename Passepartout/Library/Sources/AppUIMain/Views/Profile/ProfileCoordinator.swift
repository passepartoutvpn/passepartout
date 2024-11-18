//
//  ProfileCoordinator.swift
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
import CommonUtils
import PassepartoutKit
import SwiftUI

struct ProfileCoordinator: View {
    struct Flow {
        let onNewModule: (ModuleType) -> Void

        let onCommitEditing: () async throws -> Void

        let onCancelEditing: () -> Void
    }

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    private var iapManager: IAPManager

    let profileManager: ProfileManager

    let profileEditor: ProfileEditor

    let registry: Registry

    let moduleViewFactory: any ModuleViewFactory

    let modally: Bool

    @Binding
    var path: NavigationPath

    let onDismiss: () -> Void

    @State
    private var requiresPurchase = false

    @State
    private var requiredFeatures: Set<AppFeature> = []

    @State
    private var paywallReason: PaywallReason?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    // FIXME: #849, warn about required features
    var body: some View {
        contentView
            .modifier(PaywallModifier(reason: $paywallReason))
            .alert("Purchase required", isPresented: $requiresPurchase) {
                Button("OK", action: onDismiss)
                Button("Upgrade") {
                    paywallReason = .purchase(requiredFeatures, nil)
                }
                Button("Review", role: .cancel, action: {})
            } message: {
                Text("This profile requires paid features to work. Disable or edit the flagged modules.")
            }
            .withErrorHandler(errorHandler)
    }
}

// MARK: - Destinations

private extension ProfileCoordinator {
    var contentView: some View {
#if os(iOS)
        ProfileEditView(
            profileEditor: profileEditor,
            moduleViewFactory: moduleViewFactory,
            path: $path,
            paywallReason: $paywallReason,
            flow: .init(
                onNewModule: onNewModule,
                onCommitEditing: onCommitEditing,
                onCancelEditing: onCancelEditing
            )
        )
        .themeNavigationDetail()
        .themeNavigationStack(if: modally, path: $path)
#elseif os(macOS)
        ProfileSplitView(
            profileEditor: profileEditor,
            moduleViewFactory: moduleViewFactory,
            paywallReason: $paywallReason,
            flow: .init(
                onNewModule: onNewModule,
                onCommitEditing: onCommitEditing,
                onCancelEditing: onCancelEditing
            )
        )
#endif
    }
}

private extension ProfileCoordinator {
    func onNewModule(_ moduleType: ModuleType) {
        let module = moduleType.newModule(with: registry)
        withAnimation(theme.animation(for: .modules)) {
            profileEditor.saveModule(module, activating: true)
        }
    }

    func onCommitEditing() async throws {
        do {
            if !iapManager.isRestricted {
                try await onCommitEditingStandard()
            } else {
                try await onCommitEditingRestricted()
            }
        } catch {
            errorHandler.handle(error, title: Strings.Global.save)
            throw error
        }
    }

    // standard: always save, warn if purchase required
    func onCommitEditingStandard() async throws {
        let savedProfile = try await profileEditor.save(to: profileManager)
        do {
            try iapManager.verify(savedProfile.activeModules)
        } catch AppError.ineligibleProfile(let requiredFeatures) {
            self.requiredFeatures = requiredFeatures
            requiresPurchase = true
            return
        }
        onDismiss()
    }

    // restricted: verify before saving
    func onCommitEditingRestricted() async throws {
        do {
            try iapManager.verify(profileEditor.activeModules)
        } catch AppError.ineligibleProfile(let requiredFeatures) {
            paywallReason = .purchase(requiredFeatures)
            return
        }
        try await profileEditor.save(to: profileManager)
        onDismiss()
    }

    func onCancelEditing() {
        onDismiss()
    }
}

// MARK: - Previews

#Preview {
    ProfileCoordinator(
        profileManager: .mock,
        profileEditor: ProfileEditor(profile: .newMockProfile()),
        registry: Registry(),
        moduleViewFactory: DefaultModuleViewFactory(registry: Registry()),
        modally: false,
        path: .constant(NavigationPath()),
        onDismiss: {}
    )
    .withMockEnvironment()
}
