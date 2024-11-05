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

    @Binding
    private var reason: PaywallReason?

    @State
    private var isPresentingRestricted = false

    @State
    private var paywallArguments: PaywallArguments?

    public init(reason: Binding<PaywallReason?>) {
        _reason = reason
    }

    public func body(content: Content) -> some View {
        content
            .alert(
                Strings.Alerts.Iap.Restricted.title,
                isPresented: $isPresentingRestricted,
                actions: {
                    Button(Strings.Global.ok) {
                        reason = nil
                        isPresentingRestricted = false
                    }
                },
                message: {
                    Text(Strings.Alerts.Iap.Restricted.message)
                }
            )
            .themeModal(item: $paywallArguments) { args in
                NavigationStack {
                    PaywallView(
                        isPresented: isPresentingPurchase,
                        feature: args.feature,
                        suggestedProducts: args.products
                    )
                }
            }
            .onChange(of: reason) {
                switch $0 {
                case .restricted:
                    isPresentingRestricted = true

                case .purchase(let feature, let products):
                    paywallArguments = PaywallArguments(feature: feature, products: products)

                default:
                    break
                }
            }
    }
}

private extension PaywallModifier {
    var isPresentingPurchase: Binding<Bool> {
        Binding {
            paywallArguments != nil
        } set: {
            if !$0 {
                // make sure to reset this to allow paywall to appear again
                reason = nil
                paywallArguments = nil
            }
        }
    }
}

private struct PaywallArguments: Identifiable {
    let feature: AppFeature

    let products: Set<AppProduct>

    var id: String {
        feature.id
    }
}
