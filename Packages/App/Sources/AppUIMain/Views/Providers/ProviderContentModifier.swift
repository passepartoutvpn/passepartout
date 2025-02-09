//
//  ProviderContentModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/7/24.
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

import CommonAPI
import CommonLibrary
import PassepartoutKit
import SwiftUI

struct ProviderContentModifier<Template, ProviderRows>: ViewModifier where Template: IdentifiableConfiguration, ProviderRows: View {
    var apis: [APIMapper] = API.shared

    @Binding
    var providerId: ProviderID?

    let providerPreferences: ProviderPreferences?

    @Binding
    var selectedEntity: ProviderEntity<Template>?

    let entityDestination: any Hashable

    @Binding
    var paywallReason: PaywallReason?

    @ViewBuilder
    let providerRows: ProviderRows

    func body(content: Content) -> some View {
        debugChanges()
        return content
            .modifier(APIContentModifier(
                apis: apis,
                providerId: $providerId,
                providerPreferences: providerPreferences,
                templateType: Template.self,
                paywallReason: $paywallReason,
                providerRows: {
                    providerEntityRow
                    providerRows
                },
                onSelectProvider: onSelectProvider
            ))
    }
}

private extension ProviderContentModifier {
    var providerEntityRow: some View {
        NavigationLink(value: entityDestination) {
            HStack {
                Text(Strings.Global.Nouns.server)
                if let selectedEntity {
                    Spacer()
                    Text(selectedEntity.server.hostname ?? selectedEntity.server.serverId)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private extension ProviderContentModifier {
    func onSelectProvider(manager: APIManager, providerId: ProviderID?, isInitial: Bool) {
        if !isInitial {
            selectedEntity = nil
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        List {
            EmptyView()
                .modifier(ProviderContentModifier(
                    apis: [API.bundled],
                    providerId: .constant(.hideme),
                    providerPreferences: nil,
                    selectedEntity: .constant(nil as ProviderEntity<OpenVPNProviderTemplate>?),
                    entityDestination: "Destination",
                    paywallReason: .constant(nil),
                    providerRows: {
                        Text("Other")
                    }
                ))
        }
        .navigationTitle("Preview")
        .navigationDestination(for: String.self) {
            Text($0)
        }
    }
    .withMockEnvironment()
}
