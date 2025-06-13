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

        let onSaveProfile: () async throws -> Void

        let onCancelEditing: () -> Void

        let onSendToTV: () -> Void
    }

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    private var iapManager: IAPManager

    @EnvironmentObject
    private var preferencesManager: PreferencesManager

    @Environment(\.distributionTarget)
    private var distributionTarget

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
            .modifier(PaywallModifier(
                reason: $paywallReason,
                onAction: { action, _ in
                    switch action {
                    case .save:
                        saveProfileAnyway()
                    case .sendToTV:
                        sendProfileToTV(verifying: false)
                    default:
                        assertionFailure("Unhandled paywall action \(action)")
                    }
                }
            ))
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
            onSaveProfile: {
                try await saveProfile(verifying: true)
            },
            onCancelEditing: {
                cancelEditing()
            },
            onSendToTV: {
                sendProfileToTV(verifying: true)
            }
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
    func commitEditing(
        action: PaywallModifier.Action?,
        additionalFeatures: Set<AppFeature>? = nil,
        dismissing: Bool
    ) async throws -> Profile? {
        do {
            let savedProfile = try await profileEditor.save(
                to: profileManager,
                buildingWith: registry,
                verifyingWith: action != nil ? iapManager : nil,
                additionalFeatures: additionalFeatures,
                preferencesManager: preferencesManager
            )
            if dismissing {
                onDismiss()
            }
            return savedProfile
        } catch AppError.verificationReceiptIsLoading {
            assert(action != nil, "Verification error despite nil action (loading)")

            pp_log_g(.App.profiles, .error, "Unable to commit profile: loading receipt")
            let V = Strings.Views.Paywall.Alerts.self
            errorHandler.handle(
                title: V.Confirmation.title,
                message: [V.Verification.edit, V.Verification.boot].joined(separator: "\n\n")
            )
            return nil
        } catch AppError.verificationRequiredFeatures(let requiredFeatures) {
            assert(action != nil, "Verification error despite nil action (required)")

            pp_log_g(.App.profiles, .error, "Unable to commit profile: required features \(requiredFeatures)")
            if let action {
                setLater(PaywallReason(
                    nil,
                    requiredFeatures: requiredFeatures,
                    action: action
                )) {
                    paywallReason = $0
                }
            }
            return nil
        } catch {
            pp_log_g(.App.profiles, .fault, "Unable to commit profile: \(error)")
            throw error
        }
    }

    func cancelEditing() {
        profileEditor.discard()
        onDismiss()
    }
}

private extension ProfileCoordinator {
    func saveProfile(verifying: Bool) async throws {
        do {
            try await commitEditing(
                action: verifying ? .save : nil,
                dismissing: true
            )
        } catch {
            errorHandler.handle(error, title: Strings.Global.Actions.save)
            throw error
        }
    }

    func saveProfileAnyway() {
        Task {
            try await saveProfile(verifying: false)
        }
    }

    func sendProfileToTV(verifying: Bool) {
        Task {
            do {
                guard let profile = try await commitEditing(
                    action: verifying ? .sendToTV : nil,
                    dismissing: false
                ) else {
                    return
                }
                modalRoute = .sendToTV(profile)
            } catch {
                errorHandler.handle(error, title: Strings.Global.Actions.save)
            }
        }
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
