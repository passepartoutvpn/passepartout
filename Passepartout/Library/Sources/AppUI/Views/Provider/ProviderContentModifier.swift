//
//  ProviderContentModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/14/24.
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

import PassepartoutKit
import SwiftUI

struct ProviderContentModifier<Entity, ProviderRows>: ViewModifier where Entity: ProviderEntity, Entity.Configuration: ProviderConfigurationIdentifiable & Codable, ProviderRows: View {

    @EnvironmentObject
    private var providerManager: ProviderManager

    let apis: [APIMapper]

    @Binding
    var providerId: ProviderID?

    let entityType: Entity.Type

    let isRequired: Bool

    @ViewBuilder
    let providerRows: ProviderRows

    let onSelectProvider: (ProviderManager, ProviderID?, _ isInitial: Bool) -> Void

    func body(content: Content) -> some View {
        providerView
            .onLoad(perform: loadCurrentProvider)
            .onChange(of: providerId) { newId in
                Task {
                    if let newId {
                        await refreshInfrastructure(for: newId)
                    }
                    onSelectProvider(providerManager, newId, false)
                }
            }
            .disabled(providerManager.isLoading)

        if providerId == nil && !isRequired {
            content
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.providerId == rhs.providerId
    }
}

private extension ProviderContentModifier {

#if os(iOS)
    var providerView: some View {
        Group {
            providerPicker
            if providerId != nil {
                providerRows
                refreshButton {
                    HStack {
                        Text(Strings.Providers.refreshInfrastructure)
                        if providerManager.isLoading {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }
        }
        .themeSection(footer: lastUpdatedString)
    }
#else
    var providerView: some View {
        Group {
            providerPicker
            if providerId != nil {
                providerRows
                HStack {
                    lastUpdatedString.map {
                        Text($0)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    refreshButton {
                        Text(Strings.Providers.refreshInfrastructure)
                    }
                }
            }
        }
    }
#endif

    var providerPicker: some View {
        ProviderPicker(
            providers: supportedProviders,
            providerId: $providerId,
            isRequired: isRequired,
            isLoading: providerManager.isLoading
        )
    }

    func refreshButton<Label>(label: () -> Label) -> some View where Label: View {
        Button(action: onRefreshInfrastructure, label: label)
    }

    var supportedProviders: [ProviderMetadata] {
        providerManager
            .providers
            .filter {
                $0.supports(Entity.Configuration.self)
            }
    }

    var lastUpdate: Date? {
        guard let providerId else {
            return nil
        }
        return providerManager.lastUpdate(for: providerId)
    }

    var lastUpdatedString: String? {
        guard let lastUpdate else {
            return providerManager.isLoading ? Strings.Providers.LastUpdated.loading : nil
        }
        return Strings.Providers.lastUpdated(lastUpdate.timestamp)
    }
}

private extension ProviderContentModifier {
    func loadCurrentProvider() {
       Task {
           await refreshIndex()
           if let providerId {
               onSelectProvider(providerManager, providerId, true)
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
            try await providerManager.fetchVPNInfrastructure(from: apis, for: providerId)
            return true
        } catch {
            pp_log(.app, .error, "Unable to refresh infrastructure: \(error)")
            return false
        }
    }

    func onRefreshInfrastructure() {
        guard let providerId else {
            return
        }
        Task {
            await refreshInfrastructure(for: providerId)
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        EmptyView()
            .modifier(ProviderContentModifier(
                apis: [API.bundled],
                providerId: .constant(.hideme),
                entityType: VPNEntity<OpenVPN.Configuration>.self,
                isRequired: false,
                providerRows: {},
                onSelectProvider: { _, _, _ in }
            ))
    }
    .withMockEnvironment()
}
