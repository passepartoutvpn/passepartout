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
                    Text(restrictedMessage)
                }
            )
            .themeModal(item: $paywallArguments) { args in
                NavigationStack {
                    PaywallView(
                        isPresented: isPresentingPurchase,
                        features: iapManager.excludingEligible(from: args.features),
                        suggestedProduct: args.product
                    )
                }
                .frame(idealHeight: 500)
            }
            .onChange(of: reason) {
                switch $0 {
                case .purchase(let features, let product):
                    guard !iapManager.isRestricted else {
                        isPresentingRestricted = true
                        return
                    }
                    paywallArguments = PaywallArguments(features: features, product: product)

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

    var restrictedMessage: String {
        guard case .purchase(let features, _) = reason else {
            return ""
        }
        let msg = Strings.Alerts.Iap.Restricted.message
        return msg + "\n\n" + iapManager
            .excludingEligible(from: features)
            .map(\.localizedDescription)
            .sorted()
            .joined(separator: "\n")
    }
}

private struct PaywallArguments: Identifiable {
    let features: Set<AppFeature>

    let product: AppProduct?

    var id: [String] {
        features.map(\.id)
    }
}

private extension IAPManager {
    func excludingEligible(from features: Set<AppFeature>) -> Set<AppFeature> {
        features.filter {
            !isEligible(for: $0)
        }
    }
}
