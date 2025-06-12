//
//  PaywallModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/11/24.
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
import SwiftUI

public struct PaywallModifier: ViewModifier {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Binding
    private var reason: PaywallReason?

    private let onAction: ((Profile?) -> Void)?

    private let onCancel: (() -> Void)?

    @State
    private var isConfirming = false

    @State
    private var isPurchasing = false

    public init(
        reason: Binding<PaywallReason?>,
        onAction: ((Profile?) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        _reason = reason
        self.onAction = onAction
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
    func title(forAction action: Action) -> String {
        switch action {
        case .connect:
            return Strings.Global.Actions.connect
        case .purchase:
            return Strings.Global.Actions.purchase
        case .save:
            return Strings.Views.Paywall.Alerts.Actions.save
        }
    }

    func confirmationActions() -> some View {
        reason.map { reason in
            Group {
                if let onAction {
                    Button(title(forAction: reason.action), role: .cancel) {
                        onAction(reason.profile)
                    }
                }
                if !iapManager.isBeta {
                    Button(Strings.Global.Actions.purchase) {
                        isPurchasing = true
                    }
                }
            }
        }
    }

    var confirmationTitle: String {
        guard !iapManager.isBeta else {
            return Strings.Views.Paywall.Alerts.Restricted.title
        }
        return Strings.Views.Paywall.Alerts.Confirmation.title
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
        default:
            break
        }
        return alertMessage(
            startingWith: messages.joined(separator: " "),
            features: ineligibleFeatures
        )
    }
}

// MARK: - Restricted alert

private extension PaywallModifier {
    func restrictedActions() -> some View {
        Button(Strings.Global.Nouns.ok) {
            onCancel?()
        }
    }

    func restrictedMessage() -> some View {
        Text(restrictedMessageString)
    }

    var restrictedMessageString: String {
        let V = Strings.Views.Paywall.Alerts.self
        var messages = [V.Restricted.message]
        if reason?.action == .connect {
            messages.append(V.Confirmation.Message.connect(limitedMinutes))
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
        reason.map {
            PaywallCoordinator(
                isPresented: $isPurchasing,
                requiredFeatures: iapManager.excludingEligible(from: $0.requiredFeatures)
            )
        }
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
