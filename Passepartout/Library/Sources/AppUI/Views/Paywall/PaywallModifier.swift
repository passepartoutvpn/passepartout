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

import SwiftUI

struct PaywallModifier: ViewModifier {

    @Binding
    var reason: PaywallReason?

    @State
    private var isPresentingRestricted = false

    @State
    private var paywallFeature: AppFeature?

    func body(content: Content) -> some View {
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
            .themeModal(item: $paywallFeature) {
                PaywallView(isPresented: isPresentingPurchase, feature: $0)
            }
            .onChange(of: reason) {
                switch $0 {
                case .restricted:
                    isPresentingRestricted = true

                case .purchase(let feature):
                    paywallFeature = feature

                default:
                    break
                }
            }
    }
}

private extension PaywallModifier {
    var isPresentingPurchase: Binding<Bool> {
        Binding {
            paywallFeature != nil
        } set: {
            if !$0 {
                paywallFeature = nil
            }
        }
    }
}
