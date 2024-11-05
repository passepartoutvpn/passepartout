//
//  PurchaseButtonModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/5/24.
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

public struct PurchaseButtonModifier: ViewModifier {

    @EnvironmentObject
    private var iapManager: IAPManager

    private let title: String

    private let label: String?

    private let feature: AppFeature

    private let suggestedProduct: AppProduct?

    private let showsIfRestricted: Bool

    @Binding
    private var paywallReason: PaywallReason?

    public init(
        _ title: String,
        label: String? = nil,
        feature: AppFeature,
        suggesting suggestedProduct: AppProduct?,
        showsIfRestricted: Bool,
        paywallReason: Binding<PaywallReason?>
    ) {
        self.title = title
        self.label = label
        self.feature = feature
        self.suggestedProduct = suggestedProduct
        self.showsIfRestricted = showsIfRestricted
        _paywallReason = paywallReason
    }

    public func body(content: Content) -> some View {
        switch iapManager.paywallReason(forFeature: feature, suggesting: suggestedProduct) {
        case .purchase:
            purchaseView

        case .restricted:
            if showsIfRestricted {
                content
            }

        default:
            content
        }
    }
}

private extension PurchaseButtonModifier {
    var purchaseView: some View {
        HStack {
            if let label {
                Text(label)
                Spacer()
            }
            purchaseButton
        }
    }

    var purchaseButton: some View {
        Button(title) {
            paywallReason = .purchase(feature, suggestedProduct)
        }
    }
}
