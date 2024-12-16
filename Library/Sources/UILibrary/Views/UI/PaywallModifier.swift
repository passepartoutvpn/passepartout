//
//  PaywallModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/11/24.
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
import SwiftUI

public struct PaywallModifier: ViewModifier {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Binding
    private var reason: PaywallReason?

    private let okTitle: String?

    private let okAction: (() -> Void)?

    @State
    private var isConfirming = false

    @State
    private var isRestricted = false

    @State
    private var isPurchasing = false

    public init(
        reason: Binding<PaywallReason?>,
        okTitle: String? = nil,
        okAction: (() -> Void)? = nil
    ) {
        _reason = reason
        self.okTitle = okTitle
        self.okAction = okAction
    }

    public func body(content: Content) -> some View {
        content
            .alert(
                Strings.Views.Paywall.Alerts.Confirmation.title,
                isPresented: $isConfirming,
                actions: confirmationActions,
                message: confirmationMessage
            )
            .alert(
                Strings.Views.Paywall.Alerts.Restricted.title,
                isPresented: $isRestricted,
                actions: restrictedActions,
                message: restrictedMessage
            )
            .themeModal(
                isPresented: $isPurchasing,
                options: .init(size: .custom(width: 400, height: 400)),
                content: modalDestination
            )
            .onChange(of: isRestricted) {
                if !$0 {
                    reason = nil
                }
            }
            .onChange(of: isPurchasing) {
                if !$0 {
                    reason = nil
                }
            }
            .onChange(of: reason) {
                guard let reason = $0 else {
                    return
                }
                if !iapManager.isRestricted {
                    if reason.needsConfirmation {
                        isConfirming = true
                    } else {
                        isPurchasing = true
                    }
                } else {
                    isRestricted = true
                }
            }
    }
}

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

    func alertMessage(startingWith header: String, features: [String]) -> String {
        header + "\n\n" + features
            .joined(separator: "\n")
    }
}

private extension IAPManager {
    func excludingEligible(from features: Set<AppFeature>) -> Set<AppFeature> {
        features.filter {
            !isEligible(for: $0)
        }
    }
}

// MARK: - Confirmation alert

private extension PaywallModifier {

    @ViewBuilder
    func confirmationActions() -> some View {
        Button(Strings.Global.Actions.purchase) {
            // IMPORTANT: retain reason because it serves paywall content
            isPurchasing = true
        }
        if let okTitle {
            Button(okTitle) {
                reason = nil
                okAction?()
            }
        }
        Button(Strings.Global.Actions.cancel, role: .cancel) {
            reason = nil
        }
    }

    func confirmationMessage() -> some View {
        Text(confirmationMessageString)
    }

    var confirmationMessageString: String {
        alertMessage(
            startingWith: Strings.Views.Paywall.Alerts.Confirmation.message,
            features: ineligibleFeatures
        )
    }
}

// MARK: - Restricted alert

private extension PaywallModifier {
    func restrictedActions() -> some View {
        Button(Strings.Global.Nouns.ok) {
            //
        }
    }

    func restrictedMessage() -> some View {
        Text(restrictedMessageString)
    }

    var restrictedMessageString: String {
        alertMessage(
            startingWith: Strings.Views.Paywall.Alerts.Restricted.message,
            features: ineligibleFeatures
        )
    }
}

// MARK: - Paywall

private extension PaywallModifier {
    func modalDestination() -> some View {
        reason.map {
            PaywallView(
                isPresented: $isPurchasing,
                features: iapManager.excludingEligible(from: $0.requiredFeatures)
            )
            .themeNavigationStack()
        }
    }
}
