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
import SwiftUI

struct ProfileCoordinator: View {
    struct Flow {
        let onNewModule: (ModuleType) -> Void

        let onCommitEditing: () async throws -> Void

        let onCancelEditing: () -> Void

        let onSendToTV: () -> Void
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
    private var modalRoute: ModalRoute?

    @State
    private var paywallReason: PaywallReason?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        contentView
            .modifier(PaywallModifier(reason: $paywallReason))
            .themeModal(item: $modalRoute, content: modalDestination)
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
            flow: flow
        )
        .themeNavigationDetail()
        .themeNavigationStack(path: $path)
#else
        ProfileSplitView(
            profileManager: profileManager,
            profileEditor: profileEditor,
            moduleViewFactory: moduleViewFactory,
            paywallReason: $paywallReason,
            flow: flow
        )
#endif
    }
}

private extension ProfileCoordinator {
    enum ModalRoute: Identifiable {
        case sendToTV(Profile)

        var id: Int {
            switch self {
            case .sendToTV: 1
            }
        }
    }

    @ViewBuilder
    func modalDestination(for item: ModalRoute) -> some View {
        switch item {
        case .sendToTV(let profile):
            SendToTVCoordinator(
                profile: profile,
                isPresented: Binding(presenting: $modalRoute) {
                    switch $0 {
                    case .sendToTV:
                        return true
                    default:
                        return false
                    }
                }
            )
        }
    }

    var flow: Flow {
        Flow(
            onNewModule: addNewModule,
            onCommitEditing: {
                try await commitEditing(dismissing: true)
            },
            onCancelEditing: {
                cancelEditing()
            },
            onSendToTV: sendProfileToTV
        )
    }
}

// MARK: - Actions

private extension ProfileCoordinator {
    func addNewModule(_ moduleType: ModuleType) {
        let module = moduleType.newModule(with: registry)
        withAnimation(theme.animation(for: .modules)) {
            profileEditor.saveModule(module, activating: true)
        }
    }

    @discardableResult
    func commitEditing(dismissing: Bool) async throws -> Profile? {
        do {
            return try await commitEditing(verifying: !iapManager.isBeta, dismissing: dismissing)
        } catch {
            pp_log_g(.App.profiles, .error, "Unable to commit profile: \(error)")
            errorHandler.handle(error, title: Strings.Global.Actions.save)
            throw error
        }
    }

    @discardableResult
    func commitEditing(verifying: Bool, dismissing: Bool) async throws -> Profile? {
        let profileToSave = try profileEditor.build(with: registry)

        if verifying {
            do {
                try iapManager.verify(profileToSave, extra: profileEditor.extraFeatures)
            } catch AppError.ineligibleProfile(let requiredFeatures) {

                // still loading receipt
                guard !iapManager.isLoadingReceipt else {
                    pp_log_g(.App.profiles, .error, "Unable to commit profile: loading receipt")
                    let V = Strings.Views.Paywall.Alerts.Verification.self
                    errorHandler.handle(
                        title: Strings.Views.Paywall.Alerts.Confirmation.title,
                        message: [V.edit, V.boot].joined(separator: "\n\n")
                    )
                    return nil
                }

                // present paywall if purchase required
                guard requiredFeatures.isEmpty else {
                    pp_log_g(.App.profiles, .error, "Unable to commit profile: required features \(requiredFeatures)")
                    setLater(PaywallReason(
                        nil,
                        requiredFeatures: requiredFeatures,
                        suggestedProducts: nil,
                        action: .save
                    )) {
                        paywallReason = $0
                    }
                    return nil
                }
            }
        }

        try await profileEditor.save(
            profileToSave,
            to: profileManager,
            preferencesManager: preferencesManager
        )
        if dismissing {
            onDismiss()
        }
        return profileToSave
    }

    func cancelEditing() {
        profileEditor.discard()
        onDismiss()
    }

    func sendProfileToTV() {
        Task {
            do {
                guard let profile = try await commitEditing(dismissing: false) else {
                    return
                }
                modalRoute = .sendToTV(profile)
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}

// MARK: - Helpers

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
