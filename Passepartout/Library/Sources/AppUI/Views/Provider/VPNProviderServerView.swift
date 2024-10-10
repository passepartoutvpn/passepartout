//
//  VPNProviderServerView.swift
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

struct VPNProviderServerView<Configuration>: View where Configuration: ProviderConfigurationIdentifiable & Hashable & Codable {

    @EnvironmentObject
    private var providerManager: ProviderManager

    @EnvironmentObject
    private var vpnProviderManager: VPNProviderManager

    @Environment(\.dismiss)
    private var dismiss

    var apis: [APIMapper] = API.shared

    let providerId: ProviderID

    let onSelect: (_ server: VPNServer, _ preset: VPNPreset<Configuration>) -> Void

    @State
    private var isLoading = true

    @State
    var sortOrder = [
        KeyPathComparator(\VPNServer.sortableRegion)
    ]

    @State
    var sortedServers: [VPNServer] = []

    // FIXME: #703, flickers on appear
    var body: some View {
        serversView
            .modifier(VPNFiltersModifier<Configuration>(
                manager: vpnProviderManager,
                providerId: providerId,
                onRefresh: {
                    await refreshInfrastructure(for: providerId)
                }
            ))
            .themeAnimation(on: isLoading, category: .providers)
            .navigationTitle(providerMetadata?.description ?? Strings.Global.servers)
            .task {
                await loadInfrastructure(for: providerId)
            }
            .onReceive(vpnProviderManager.$filteredServers, perform: onFilteredServers)
    }
}

private extension VPNProviderServerView {
    var providerMetadata: ProviderMetadata? {
        providerManager.metadata(withId: providerId)
    }
}

// MARK: - Actions

extension VPNProviderServerView {
    func onFilteredServers(_ servers: [String: VPNServer]) {
        sortedServers = servers
            .values
            .sorted(using: sortOrder)
    }

    func selectServer(_ server: VPNServer) {
        guard let preset = compatiblePreset(with: server) else {
            // FIXME: #703, alert select a preset
            return
        }
        onSelect(server, preset)
        dismiss()
    }
}

private extension VPNProviderServerView {
    func compatiblePreset(with server: VPNServer) -> VPNPreset<Configuration>? {
        vpnProviderManager
            .presets(ofType: Configuration.self)
            .first {
                if let supportedIds = server.provider.supportedPresetIds {
                    return supportedIds.contains($0.presetId)
                }
                return true
            }
    }

    func loadInfrastructure(for providerId: ProviderID) async {
        await vpnProviderManager.setProvider(providerId)
        if await vpnProviderManager.lastUpdated() == nil {
            await refreshInfrastructure(for: providerId)
        }
        isLoading = false
    }

    // FIXME: #704, rate-limit fetch
    func refreshInfrastructure(for providerId: ProviderID) async {
        do {
            isLoading = true
            try await vpnProviderManager.fetchInfrastructure(
                from: apis,
                for: providerId,
                ofType: Configuration.self
            )
            isLoading = false
        } catch {
            // FIXME: #703, alert unable to refresh infrastructure
            pp_log(.app, .error, "Unable to refresh infrastructure: \(error)")
            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VPNProviderServerView<OpenVPN.Configuration>(apis: [API.bundled], providerId: .protonvpn) { _, _ in
        }
    }
    .withMockEnvironment()
}
