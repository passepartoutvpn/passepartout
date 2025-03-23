//
//  ProfileCoordinator.swift
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

    @EnvironmentObject
    private var preferencesManager: PreferencesManager

    let profileManager: ProfileManager

    let profileEditor: ProfileEditor

    let registry: Registry

    let moduleViewFactory: any ModuleViewFactory

    @Binding
    var path: NavigationPath

    let onDismiss: () -> Void

    @State
    private var paywallReason: PaywallReason?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        contentView
            .modifier(PaywallModifier(reason: $paywallReason))
            .environment(\.dismissProfile, onDismiss)
            .withErrorHandler(errorHandler)
    }
}

// MARK: - Destinations

private extension ProfileCoordinator {
    var contentView: some View {
#if os(iOS)
        ProfileEditView(
            profileManager: profileManager,
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
        .themeNavigationStack(path: $path)
#else
        ProfileSplitView(
            profileManager: profileManager,
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
            try await onCommitEditing(verifying: !iapManager.isBeta)
        } catch {
            errorHandler.handle(error, title: Strings.Global.Actions.save)
            throw error
        }
    }

    func onCommitEditing(verifying: Bool) async throws {
        let profileToSave = try profileEditor.build(with: registry)

        if verifying {
            do {
                try iapManager.verify(profileToSave, extra: profileEditor.extraFeatures)
            } catch AppError.ineligibleProfile(let requiredFeatures) {
                guard !iapManager.isLoadingReceipt else {
                    let V = Strings.Views.Paywall.Alerts.Verification.self
                    errorHandler.handle(
                        title: Strings.Views.Paywall.Alerts.Confirmation.title,
                        message: [V.edit, V.boot].joined(separator: "\n\n")
                    )
                    return
                }

                // present paywall if purchase required
                guard requiredFeatures.isEmpty else {
                    paywallReason = .init(
                        nil,
                        requiredFeatures: requiredFeatures,
                        suggestedProducts: nil,
                        action: .save
                    )
                    return
                }
            }
        }

        try await profileEditor.save(
            profileToSave,
            to: profileManager,
            preferencesManager: preferencesManager
        )
        onDismiss()
    }

    func onCancelEditing() {
        profileEditor.discard()
        onDismiss()
    }
}

private extension ProfileEditor {
    var extraFeatures: Set<AppFeature> {
        var list: Set<AppFeature> = []
        if isShared {
            list.insert(.sharing)
            if isAvailableForTV {
                list.insert(.appleTV)
            }
        }
        return list
    }
}

// MARK: - Previews

#Preview {
    ProfileCoordinator(
        profileManager: .forPreviews,
        profileEditor: ProfileEditor(profile: .newMockProfile()),
        registry: Registry(),
        moduleViewFactory: DefaultModuleViewFactory(registry: Registry()),
        path: .constant(NavigationPath()),
        onDismiss: {}
    )
    .withMockEnvironment()
}
