//
//  ProviderPicker.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/15/24.
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
import PassepartoutKit
import SwiftUI

struct ProviderPicker: View {
    let providers: [ProviderMetadata]

    @Binding
    var providerId: ProviderID?

    let isRequired: Bool

    let isLoading: Bool

    @Binding
    var paywallReason: PaywallReason?

    var body: some View {
        Picker(selection: $providerId) {
            if !providers.isEmpty {
                Text(isRequired ? Strings.Providers.selectProvider : Strings.Providers.noProvider)
                    .tag(nil as ProviderID?)
                ForEach(providers, id: \.id) {
                    Text($0.description)
                        .tag($0.id as ProviderID?)
                }
            } else {
                Text(isLoading ? Strings.Global.loading : Strings.Global.none)
                    .tag(providerId) // tag always exists
            }
        } label: {
            HStack {
                Text(Strings.Global.provider)
                PurchaseRequiredButton(for: providerId, paywallReason: $paywallReason)
            }
        }
        .disabled(isLoading || providers.isEmpty)
    }
}
