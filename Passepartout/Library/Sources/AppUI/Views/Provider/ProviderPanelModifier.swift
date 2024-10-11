//
//  ProviderPanelModifier.swift
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

import AppLibrary
import PassepartoutKit
import SwiftUI

struct ProviderPanelModifier<Entity, ProviderContent>: ViewModifier where Entity: ProviderEntity, Entity.Configuration: ProviderConfigurationIdentifiable & Codable, ProviderContent: View {

    @EnvironmentObject
    private var providerManager: ProviderManager

    var apis: [APIMapper] = API.shared

    let isRequired: Bool

    @Binding
    var providerId: ProviderID?

    @Binding
    var selectedEntity: Entity?

    @ViewBuilder
    let providerContent: (ProviderID, Entity?) -> ProviderContent

    func body(content: Content) -> some View {
        providerPicker
            .task {
                await refreshIndex()
            }

        if let providerId {
            providerContent(providerId, selectedEntity)
        } else {
            content
        }
    }
}

private extension ProviderPanelModifier {
    var supportedProviders: [ProviderMetadata] {
        providerManager.providers.filter {
            $0.supports(Entity.Configuration.self)
        }
    }

    var selectedProviderId: Binding<ProviderID?> {
        Binding {
            providerId ?? supportedProviders.first?.id
        } set: {
            self.providerId = $0
        }
    }

    var providerPicker: some View {
        let hasProviders = !supportedProviders.isEmpty
        return Picker(Strings.Global.provider, selection: selectedProviderId) {
            if hasProviders {
                if !isRequired {
                    Text(Strings.Global.none)
                        .tag(nil as ProviderID?)
                }
                ForEach(supportedProviders, id: \.id) {
                    Text($0.description)
                        .tag($0.id as ProviderID?)
                }
            } else {
                Text(" ") // enforce constant picker height on iOS
                    .tag(providerId) // tag always exists
            }
        }
        .onChange(of: providerId) { _ in
            selectedEntity = nil
        }
        .disabled(!hasProviders)
    }
}

private extension ProviderPanelModifier {

    // FIXME: #707, fetch bundled providers on launch
    // FIXME: #704, rate-limit fetch
    func refreshIndex() async {
        do {
            try await providerManager.fetchIndex(from: apis)
        } catch {
            pp_log(.app, .error, "Unable to fetch index: \(error)")
        }
    }
}

private extension ProviderID {
    var nilIfEmpty: ProviderID? {
        !rawValue.isEmpty ? self : nil
    }
}

// MARK: - Preview

#Preview {
    @State
    var providerId: ProviderID? = .hideme

    @State
    var vpnEntity: VPNEntity<OpenVPN.Configuration>?

    return List {
        EmptyView()
            .modifier(ProviderPanelModifier(
                apis: [API.bundled],
                isRequired: false,
                providerId: $providerId,
                selectedEntity: $vpnEntity,
                providerContent: { _, entity in
                    HStack {
                        Text("Server")
                        Spacer()
                        Text(entity?.server.serverId ?? "None")
                    }
                }
            ))
    }
    .withMockEnvironment()
}
