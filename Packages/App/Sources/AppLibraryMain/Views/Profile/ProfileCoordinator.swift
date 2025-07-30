// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

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

    @EnvironmentObject
    private var configManager: ConfigManager

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
            .modifier(DynamicPaywallModifier(
                configManager: configManager,
                paywallReason: $paywallReason
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
            onCancelEditing: cancelEditing,
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
    func commitEditing(
        action: PaywallModifier.Action?,
        dismissing: Bool
    ) async throws -> Profile? {
        do {
            let savedProfile = try await profileEditor.save(
                to: profileManager,
                buildingWith: registry,
                verifyingWith: action != nil ? iapManager : nil,
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
                let nextReason = PaywallReason(
                    nil,
                    requiredFeatures: requiredFeatures,
                    action: action
                )
                setLater(nextReason) {
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
                action: verifying ? paywallSaveAction : nil,
                dismissing: true
            )
        } catch {
            errorHandler.handle(error, title: Strings.Global.Actions.save)
            throw error
        }
    }

    func sendProfileToTV() {
        Task {
            do {
                let profile = try await profileEditor.save(
                    to: nil,
                    buildingWith: registry,
                    verifyingWith: nil,
                    preferencesManager: preferencesManager
                )
                modalRoute = .sendToTV(profile)
            } catch {
                errorHandler.handle(error, title: Strings.Global.Actions.save)
            }
        }
    }
}

// MARK: - Paywall

private struct DynamicPaywallModifier: ViewModifier {

    @ObservedObject
    var configManager: ConfigManager

    @Binding
    var paywallReason: PaywallReason?

    func body(content: Content) -> some View {
        if configManager.isActive(.newPaywall) {
            content.modifier(newModifier)
        } else {
            content.modifier(oldModifier)
        }
    }

    var newModifier: some ViewModifier {
        NewPaywallModifier(
            reason: $paywallReason,
            onAction: { action, _ in
                switch action {
                case .cancel:
                    break
                default:
                    assertionFailure("Unhandled paywall action \(action)")
                }
            }
        )
    }

    var oldModifier: some ViewModifier {
        PaywallModifier(reason: $paywallReason)
    }
}

private extension ProfileCoordinator {
    var paywallSaveAction: PaywallModifier.Action {
        configManager.isActive(.newPaywall) ? .cancel : .save
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
