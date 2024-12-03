//
//  VPNProviderContentModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/7/24.
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

import CommonAPI
import CommonLibrary
import PassepartoutKit
import SwiftUI

struct VPNProviderContentModifier<Configuration, ProviderRows>: ViewModifier where Configuration: ProviderConfigurationIdentifiable, ProviderRows: View {
    var apis: [APIMapper] = API.shared

    @Binding
    var providerId: ProviderID?

    @Binding
    var selectedEntity: VPNEntity<Configuration>?

    @Binding
    var paywallReason: PaywallReason?

    let entityDestination: any Hashable

    @ViewBuilder
    let providerRows: ProviderRows

    func body(content: Content) -> some View {
        debugChanges()
        return content
            .modifier(ProviderContentModifier(
                apis: apis,
                providerId: $providerId,
                entityType: VPNEntity<Configuration>.self,
                paywallReason: $paywallReason,
                providerRows: {
                    providerEntityRow
                    providerRows
                },
                onSelectProvider: onSelectProvider
            ))
    }
}

private extension VPNProviderContentModifier {
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

private extension VPNProviderContentModifier {
    func onSelectProvider(manager: ProviderManager, providerId: ProviderID?, isInitial: Bool) {
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
                .modifier(VPNProviderContentModifier(
                    apis: [API.bundled],
                    providerId: .constant(.hideme),
                    selectedEntity: .constant(nil as VPNEntity<OpenVPN.Configuration>?),
                    paywallReason: .constant(nil),
                    entityDestination: "Destination",
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
