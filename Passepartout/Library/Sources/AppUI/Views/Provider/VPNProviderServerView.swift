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
import Combine
import CommonLibrary
import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct VPNProviderServerView<Configuration>: View where Configuration: ProviderConfigurationIdentifiable & Codable {
    var apis: [APIMapper] = API.shared

    let moduleId: UUID

    let providerId: ProviderID

    let configurationType: Configuration.Type

    let selectedEntity: VPNEntity<Configuration>?

    let filtersWithSelection: Bool

    let selectTitle: String

    let onSelect: (VPNServer, VPNPreset<Configuration>) -> Void

    @StateObject
    private var vpnManager = VPNProviderManager<Configuration>(sorting: [
        .localizedCountry,
        .area,
        .hostname
    ])

    @StateObject
    private var filtersViewModel = VPNFiltersView.Model()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        debugChanges()
        return contentView
            .navigationTitle(Strings.Global.servers)
            .themeNavigationDetail()
            .withErrorHandler(errorHandler)
    }
}

extension VPNProviderServerView {
    var serversView: ServersView {
        ServersView(
            vpnManager: vpnManager,
            filtersViewModel: filtersViewModel,
            apis: apis,
            moduleId: moduleId,
            providerId: providerId,
            selectedServerId: selectedEntity?.server.id,
            initialFilters: {
                guard let selectedEntity, filtersWithSelection else {
                    return nil
                }
                return VPNFilters(with: selectedEntity.server.provider)
            }(),
            selectTitle: selectTitle,
            onSelect: onSelect,
            errorHandler: errorHandler
        )
    }

    var filtersView: some View {
        VPNFiltersView(model: filtersViewModel)
    }
}

// MARK: - Subviews

extension VPNProviderServerView {
    struct ServersView: View {

        @EnvironmentObject
        private var providerManager: ProviderManager

        let vpnManager: VPNProviderManager<Configuration>

        let filtersViewModel: VPNFiltersView.Model

        let apis: [APIMapper]

        let moduleId: UUID

        let providerId: ProviderID

        let selectedServerId: String?

        let initialFilters: VPNFilters?

        let selectTitle: String

        let onSelect: (VPNServer, VPNPreset<Configuration>) -> Void

        @ObservedObject
        var errorHandler: ErrorHandler

        @State
        private var servers: [VPNServer] = []

        @State
        private var isFiltering = false

        @State
        private var onlyShowsFavorites = false

        @StateObject
        private var favoritesManager = ProviderFavoritesManager()

        var body: some View {
            debugChanges()
            return ServersSubview(
                servers: filteredServers,
                selectedServerId: selectedServerId,
                isFiltering: isFiltering,
                filtersViewModel: filtersViewModel,
                favoritesManager: favoritesManager,
                selectTitle: selectTitle,
                onSelect: onSelectServer
            )
            .task {
                do {
                    favoritesManager.moduleId = moduleId
                    vpnManager.repository = try await providerManager.vpnRepository(
                        from: apis,
                        for: providerId
                    )
                    filtersViewModel.load(
                        with: vpnManager,
                        initialFilters: initialFilters
                    )
                    await reloadServers(filters: filtersViewModel.filters)
                } catch {
                    pp_log(.app, .error, "Unable to load VPN repository: \(error)")
                    errorHandler.handle(error, title: Strings.Global.servers)
                }
            }
            .onReceive(filtersViewModel.filtersDidChange) { newValue in
                Task {
                    await reloadServers(filters: newValue)
                }
            }
            .onReceive(filtersViewModel.onlyShowsFavoritesDidChange) { newValue in
                onlyShowsFavorites = newValue
            }
            .onDisappear {
                favoritesManager.save()
            }
        }
    }
}

private extension VPNProviderServerView.ServersView {
    var filteredServers: [VPNServer] {
        if onlyShowsFavorites {
            return servers.filter {
                favoritesManager.serverIds.contains($0.serverId)
            }
        }
        return servers
    }

    func reloadServers(filters: VPNFilters) async {
        isFiltering = true
        await Task {
            servers = await vpnManager.filteredServers(with: filters)
            isFiltering = false
        }.value
    }

    func compatiblePreset(with server: VPNServer) -> VPNPreset<Configuration>? {
        vpnManager
            .presets
            .first {
                if let supportedIds = server.provider.supportedPresetIds {
                    return supportedIds.contains($0.presetId)
                }
                return true
            }
    }

    func onSelectServer(_ server: VPNServer) {
        guard let preset = compatiblePreset(with: server) else {
            pp_log(.app, .error, "Unable to find a compatible preset. Supported IDs: \(server.provider.supportedPresetIds ?? [])")
            assertionFailure("No compatible presets for server \(server.serverId) (provider=\(vpnManager.providerId), configuration=\(Configuration.providerConfigurationIdentifier), supported=\(server.provider.supportedPresetIds ?? []))")
            return
        }
        onSelect(server, preset)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VPNProviderServerView(
            apis: [API.bundled],
            moduleId: UUID(),
            providerId: .protonvpn,
            configurationType: OpenVPN.Configuration.self,
            selectedEntity: nil,
            filtersWithSelection: false,
            selectTitle: "Select",
            onSelect: { _, _ in }
        )
    }
    .withMockEnvironment()
}
