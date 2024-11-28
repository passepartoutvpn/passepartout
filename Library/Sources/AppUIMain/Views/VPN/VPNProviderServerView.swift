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

import CommonAPI
import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI

struct VPNProviderServerView<Configuration>: View where Configuration: ProviderConfigurationIdentifiable & Codable {

    @EnvironmentObject
    private var providerManager: ProviderManager

    var apis: [APIMapper] = API.shared

    let moduleId: UUID

    let providerId: ProviderID

    let configurationType: Configuration.Type

    let selectedEntity: VPNEntity<Configuration>?

    let filtersWithSelection: Bool

    var selectTitle = Strings.Views.Providers.selectEntity

    let onSelect: (VPNServer, VPNPreset<Configuration>) -> Void

    @StateObject
    private var vpnManager = VPNProviderManager<Configuration>(sorting: [
        .localizedCountry,
        .area,
        .serverId
    ])

    @State
    private var servers: [VPNServer] = []

    @State
    private var isFiltering = false

    @State
    private var onlyShowsFavorites = false

    @StateObject
    private var filtersViewModel = VPNFiltersView.Model()

    @StateObject
    private var favoritesManager = ProviderFavoritesManager()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        debugChanges()
        return ContainerView(
            content: contentView,
            filters: filtersView
        )
        .navigationTitle(title)
        .themeNavigationDetail()
        .withErrorHandler(errorHandler)
    }
}

extension VPNProviderServerView {
    func contentView() -> some View {
        ContentView(
            apis: apis,
            providerId: providerId,
            servers: filteredServers,
            selectedServer: selectedEntity?.server,
            isFiltering: isFiltering,
            filtersViewModel: filtersViewModel,
            favoritesManager: favoritesManager,
            selectTitle: selectTitle,
            onSelect: onSelectServer
        )
        .task {
            await loadInitialServers()
        }
        .onReceive(filtersViewModel.$filters.dropFirst(), perform: onNewFilters)
        .onReceive(filtersViewModel.$onlyShowsFavorites, perform: onToggleFavorites)
        .onDisappear(perform: onDisappear)
    }

    func filtersView() -> some View {
        VPNFiltersView(
            apis: apis,
            providerId: providerId,
            model: filtersViewModel
        )
    }
}

private extension VPNProviderServerView {
    var title: String {
        providerManager.provider(withId: providerId)?.description ?? Strings.Global.Nouns.servers
    }

    var filteredServers: [VPNServer] {
        if onlyShowsFavorites {
            return servers.filter {
                favoritesManager.serverIds.contains($0.serverId)
            }
        }
        return servers
    }

    var initialFilters: VPNFilters? {
        guard let selectedEntity, filtersWithSelection else {
            return nil
        }
        var filters = VPNFilters()
        filters.categoryName = selectedEntity.server.provider.categoryName
#if os(macOS)
        filters.countryCode = selectedEntity.server.provider.countryCode
#endif
        return filters
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
}

private extension VPNProviderServerView {
    func loadInitialServers() async {
        do {
            favoritesManager.moduleId = moduleId
            let repository = try await providerManager.vpnServerRepository(
                from: apis,
                for: providerId
            )
            try await vpnManager.setRepository(repository)
            filtersViewModel.load(options: vpnManager.options, initialFilters: initialFilters)
            await reloadServers(filters: filtersViewModel.filters)
        } catch {
            pp_log(.app, .error, "Unable to load VPN repository: \(error)")
            errorHandler.handle(error, title: Strings.Global.Nouns.servers)
        }
    }

    func reloadServers(filters: VPNFilters) async {
        isFiltering = true
        do {
            try await Task {
                servers = try await vpnManager.filteredServers(with: filters)
                filtersViewModel.update(with: servers)
                isFiltering = false
            }.value
        } catch {
            pp_log(.app, .error, "Unable to fetch filtered servers: \(error)")
        }
    }

    func onNewFilters(_ filters: VPNFilters) {
        Task {
            await reloadServers(filters: filters)
        }
    }

    func onToggleFavorites(_ only: Bool) {
        onlyShowsFavorites = only
    }

    func onDisappear() {
        favoritesManager.save()
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
