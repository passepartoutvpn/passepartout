// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import SwiftUI

public struct PaywallModifier: ViewModifier {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Binding
    private var reason: PaywallReason?

    private let otherTitle: String?

    private let onOtherAction: ((Profile?) -> Void)?

    private let onCancel: (() -> Void)?

    @State
    private var isConfirming = false

    @State
    private var isPurchasing = false

    public init(
        reason: Binding<PaywallReason?>,
        otherTitle: String? = nil,
        onOtherAction: ((Profile?) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        _reason = reason
        self.otherTitle = otherTitle
        self.onOtherAction = onOtherAction
        self.onCancel = onCancel
    }

    public func body(content: Content) -> some View {
        content
            .alert(
                confirmationTitle,
                isPresented: $isConfirming,
                actions: confirmationActions,
                message: confirmationMessage
            )
            .themeModal(
                isPresented: $isPurchasing,
                options: .init(size: .custom(width: 400, height: 400)),
                content: modalDestination
            )
            .onChange(of: isPurchasing) {
                if !$0 {
                    reason = nil
                }
            }
            .onChange(of: reason) {
                guard let reason = $0 else {
                    return
                }
                Task {
                    if !iapManager.isEnabled {
                        pp_log_g(.App.iap, .info, "In-app purchases are disabled, enabling...")
                        await iapManager.enable()
                        guard !iapManager.isEligible(for: reason.requiredFeatures) else {
                            pp_log_g(.App.iap, .info, "Skipping paywall because eligible for features: \(reason.requiredFeatures)")
                            return
                        }
                    }
                    if reason.needsConfirmation {
                        isConfirming = true
                    } else {
                        guard !iapManager.isBeta else {
                            assertionFailure("Purchasing in beta?")
                            return
                        }
                        isPurchasing = true
                    }
                }
            }
    }
}

private extension PaywallModifier {
    func alertMessage(startingWith header: String, features: [String]) -> String {
        header + "\n\n" + features.joined(separator: "\n")
    }
}

// MARK: - Confirmation alert

private extension PaywallModifier {

    @ViewBuilder
    func confirmationActions() -> some View {
#if !os(tvOS)
        if !iapManager.isBeta, let otherTitle, let onOtherAction {
            Button(otherTitle) {
                onOtherAction(reason?.profile)
            }
        }
#endif
        Button(Strings.Global.Nouns.ok, role: .cancel) {
            reason = nil
            onCancel?()
        }
    }

    var confirmationTitle: String {
        Strings.Views.Paywall.Alerts.Confirmation.title
    }

    func confirmationMessage() -> some View {
        Text(confirmationMessageString)
    }

    var confirmationMessageString: String {
        let V = Strings.Views.Paywall.Alerts.Confirmation.self
        var messages = [V.message]
        switch reason?.action {
        case .connect:
            messages.append(V.Message.connect(limitedMinutes))
        case .save:
            messages.append(V.Message.save)
        default:
            break
        }
        return alertMessage(
            startingWith: messages.joined(separator: " "),
            features: ineligibleFeatures
        )
    }
}

// MARK: - Paywall

private extension PaywallModifier {
    func modalDestination() -> some View {
#if !os(tvOS)
        reason.map {
            PaywallView(
                isPresented: $isPurchasing,
                requiredFeatures: iapManager.excludingEligible(from: $0.requiredFeatures),
                suggestedProducts: $0.suggestedProducts
            )
            .themeNavigationStack()
        }
#else
        fatalError("tvOS: Paywall unsupported")
#endif
    }
}

// MARK: - Logic

private extension PaywallModifier {
    var ineligibleFeatures: [String] {
        guard let reason else {
            return []
        }
        return iapManager
            .excludingEligible(from: reason.requiredFeatures)
            .map(\.localizedDescription)
            .sorted()
    }

    var limitedMinutes: Int {
        iapManager.verificationDelayMinutes
    }
}

private extension IAPManager {
    func excludingEligible(from features: Set<AppFeature>) -> Set<AppFeature> {
        features.filter {
            !isEligible(for: $0)
        }
    }
}
