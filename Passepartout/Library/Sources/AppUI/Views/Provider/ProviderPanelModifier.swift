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
import UtilsLibrary

// FIXME: #703, providers UI, reorg subviews

struct ProviderPanelModifier<Entity, ProviderContent>: ViewModifier where Entity: ProviderEntity, Entity.Configuration: ProviderConfigurationIdentifiable & Codable, ProviderContent: View {

    @EnvironmentObject
    private var providerManager: ProviderManager

    var apis: [APIMapper] = API.shared

    let isRequired: Bool

    let entityType: Entity.Type

    @Binding
    var providerId: ProviderID?

    @ViewBuilder
    let providerContent: (ProviderID) -> ProviderContent

    let onSelectProvider: (ProviderManager) -> Void

    func body(content: Content) -> some View {
        debugChanges()
        return Group {
            providerPicker
                .onLoad(perform: loadCurrentProvider)

            if let providerId {
                providerContent(providerId)
                    .asSectionWithTrailingContent {
                        refreshButton
                    }
                    .disabled(providerManager.isLoading)
            } else if !isRequired {
                content
            }
        }
    }
}

private extension ProviderPanelModifier {
    var supportedProviders: [ProviderMetadata] {
        providerManager.providers.filter {
            $0.supports(Entity.Configuration.self)
        }
    }

    var providerPicker: some View {
        let hasProviders = !supportedProviders.isEmpty
        return Picker(Strings.Global.provider, selection: $providerId) {
            if hasProviders {
                // FIXME: #703, providers UI
                Text("Select a provider")
                    .tag(nil as ProviderID?)
                ForEach(supportedProviders, id: \.id) {
                    Text($0.description)
                        .tag($0.id as ProviderID?)
                }
            } else {
                // enforce constant picker height on iOS
                Text(providerManager.isLoading ? "..." : "Unavailable")
                    .tag(providerId) // tag always exists
            }
        }
        .onChange(of: providerId) { newId in
            Task {
                if let newId {
                    await refreshInfrastructure(for: newId)
                }
                onSelectProvider(providerManager)
            }
        }
        .disabled(!hasProviders)
    }

    var refreshButton: some View {
        Button {
            guard let providerId else {
                return
            }
            Task {
                await refreshInfrastructure(for: providerId)
            }
        } label: {
            HStack {
                Text(Strings.Views.Provider.Vpn.refreshInfrastructure)
#if os(iOS)
                if let providerId, providerManager.pendingServices.contains(.provider(providerId)) {
                    Spacer()
                    ProgressView()
                }
#endif
            }
        }
        .disabled(providerManager.isLoading || providerId == nil)
    }
}

private extension ProviderPanelModifier {
    func loadCurrentProvider() {
       Task {
           if let providerId {
               async let index = await refreshIndex()
               async let provider = await refreshInfrastructure(for: providerId)
               _ = await (index, provider)
               onSelectProvider(providerManager)
           } else {
               await refreshIndex()
           }
       }
    }

    @discardableResult
    func refreshIndex() async -> Bool {
        do {
            try await providerManager.fetchIndex(from: apis)
            return true
        } catch {
            pp_log(.app, .error, "Unable to fetch index: \(error)")
            return false
        }
    }

    @discardableResult
    func refreshInfrastructure(for providerId: ProviderID) async -> Bool {
        do {
            try await providerManager.fetchVPNInfrastructure(
                from: apis,
                for: providerId,
                ofType: Entity.Configuration.self
            )
            return true
        } catch {
            // FIXME: #703, alert unable to refresh infrastructure
            pp_log(.app, .error, "Unable to refresh infrastructure: \(error)")
            return false
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
    List {
        EmptyView()
            .modifier(ProviderPanelModifier(
                apis: [API.bundled],
                isRequired: false,
                entityType: VPNEntity<OpenVPN.Configuration>.self,
                providerId: .constant(.hideme),
                providerContent: { _ in
                    Text("Server")
                },
                onSelectProvider: { _ in }
            ))
    }
    .withMockEnvironment()
}
