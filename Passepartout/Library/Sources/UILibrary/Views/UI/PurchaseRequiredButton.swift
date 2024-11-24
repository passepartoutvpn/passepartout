//
//  PurchaseRequiredButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/17/24.
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

public struct PurchaseRequiredButton: View {

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    private var iapManager: IAPManager

    private let features: Set<AppFeature>?

    @Binding
    private var paywallReason: PaywallReason?

    public init(for requiring: AppFeatureRequiring?, paywallReason: Binding<PaywallReason?>) {
        features = requiring?.features
        _paywallReason = paywallReason
    }

    public init(features: Set<AppFeature>?, paywallReason: Binding<PaywallReason?>) {
        self.features = features
        _paywallReason = paywallReason
    }

    public var body: some View {
        Button {
            guard let features, !isEligible else {
                return
            }
            setLater(.purchase(features)) {
                paywallReason = $0
            }
        } label: {
            ThemeImage(iapManager.isRestricted ? .warning : .upgrade)
                .help(helpMessage)
        }
#if os(iOS)
        .buttonStyle(.plain)
#else
        .imageScale(.large)
        .buttonStyle(.borderless)
#endif
        .foregroundStyle(theme.upgradeColor)
        .opaque(!isEligible)
    }
}

private extension PurchaseRequiredButton {
    var isEligible: Bool {
        if let features {
            return iapManager.isEligible(for: features)
        }
        return true
    }

    var helpMessage: String {
        iapManager.isRestricted ? Strings.Views.Ui.PurchaseRequired.Restricted.help : Strings.Views.Ui.PurchaseRequired.Purchase.help
    }
}
