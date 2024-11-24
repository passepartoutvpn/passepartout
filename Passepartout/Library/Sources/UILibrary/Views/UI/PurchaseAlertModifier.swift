//
//  PurchaseAlertModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/23/24.
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

import CommonIAP
import CommonUtils
import SwiftUI

public struct PurchaseAlertModifier: ViewModifier {

    @Binding
    private var isPresented: Bool

    @Binding
    private var paywallReason: PaywallReason?

    private let requiredFeatures: Set<AppFeature>

    private let okTitle: String?

    private let okAction: (() -> Void)?

    public init(
        isPresented: Binding<Bool>,
        paywallReason: Binding<PaywallReason?>,
        requiredFeatures: Set<AppFeature>,
        okTitle: String? = nil,
        okAction: (() -> Void)? = nil
    ) {
        _isPresented = isPresented
        _paywallReason = paywallReason
        self.requiredFeatures = requiredFeatures
        self.okTitle = okTitle
        self.okAction = okAction
    }

    public func body(content: Content) -> some View {
        content
            .alert(Strings.Views.Ui.PurchaseAlert.title, isPresented: $isPresented) {
                Button(Strings.Global.Actions.purchase) {
                    setLater(.purchase(requiredFeatures, nil)) {
                        paywallReason = $0
                    }
                }
                if let okTitle {
                    Button(okTitle) {
                        okAction?()
                    }
                }
                Button(Strings.Global.Actions.cancel, role: .cancel, action: {})
            } message: {
                Text(purchaseMessage)
            }
    }
}

private extension PurchaseAlertModifier {
    var purchaseMessage: String {
        let msg = Strings.Views.Ui.PurchaseAlert.message
        return msg + "\n\n" + requiredFeatures
            .map(\.localizedDescription)
            .joined(separator: "\n")
    }
}
