//
//  ProviderServerView.swift
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
import CommonUtils
import PassepartoutKit
import SwiftUI

struct ProviderServerView<Template>: View where Template: IdentifiableConfiguration {

    @EnvironmentObject
    private var apiManager: APIManager

    @EnvironmentObject
    private var preferencesManager: PreferencesManager

    let moduleId: UUID

    let providerId: ProviderID

    let selectedEntity: ProviderEntity<Template>?

    let filtersWithSelection: Bool

    var selectTitle = Strings.Views.Providers.selectEntity

    let onSelect: (ProviderServer, ProviderHeuristic?, ProviderPreset<Template>) -> Void

    @StateObject
    private var providerManager = ProviderManager<Template>(sorting: [
        .localizedCountry,
        .area,
        .serverId
    ])

    @State
    private var servers: [ProviderServer] = []

    @State
    private var isFiltering = false

    @State
    private var onlyShowsFavorites = false

    @State
    private var heuristic: ProviderHeuristic?

    @StateObject
    private var providerPreferences = ProviderPreferences()

    @StateObject
    private var filtersViewModel = ProviderFiltersView.Model()

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

extension ProviderServerView {
    func contentView() -> some View {
        ContentView(
            providerId: providerId,
            servers: filteredServers,
            selectedServer: selectedEntity?.server,
            heuristic: $heuristic,
            isFiltering: isFiltering,
            filtersViewModel: filtersViewModel,
            providerPreferences: providerPreferences,
            selectTitle: selectTitle,
            onSelect: onSelectServer
        )
        .onLoad {
            heuristic = selectedEntity?.heuristic
        }
        .task {
            await loadInitialServers()
        }
        .onReceive(filtersViewModel.$filters.dropFirst(), perform: onNewFilters)
        .onReceive(filtersViewModel.$onlyShowsFavorites, perform: onToggleFavorites)
        .onDisappear(perform: onDisappear)
    }

    func filtersView() -> some View {
        ProviderFiltersView(
            providerId: providerId,
            model: filtersViewModel,
            heuristic: $heuristic
        )
    }
}

private extension ProviderServerView {
    var title: String {
        apiManager.provider(withId: providerId)?.description ?? Strings.Global.Nouns.servers
    }

    var filteredServers: [ProviderServer] {
        if onlyShowsFavorites {
            return servers.filter {
                providerPreferences.isFavoriteServer($0.regionId)
            }
        }
        return servers
    }

    var initialFilters: ProviderFilters? {
        guard let selectedEntity else {
            return nil
        }
        var filters = ProviderFilters()
        filters.presetId = selectedEntity.preset.presetId
        if filtersWithSelection {
            filters.categoryName = selectedEntity.server.metadata.categoryName
#if os(macOS)
            filters.countryCode = selectedEntity.server.metadata.countryCode
#endif
        }
        return filters
    }

    func loadInitialServers() async {
        do {
            let repository = try preferencesManager.preferencesRepository(forProviderWithId: providerId)
            providerPreferences.setRepository(repository)
        } catch {
            pp_log(.app, .error, "Unable to load preferences for provider \(providerId): \(error)")
        }
        do {
            let repository = try await apiManager.providerRepository(for: providerId)
            try await providerManager.setRepository(repository)
            filtersViewModel.load(options: providerManager.options, initialFilters: initialFilters)
            await reloadServers(filters: filtersViewModel.filters)
        } catch {
            pp_log(.app, .error, "Unable to load VPN servers for provider \(providerId): \(error)")
            errorHandler.handle(error, title: Strings.Global.Nouns.servers)
        }
    }

    func reloadServers(filters: ProviderFilters) async {
        isFiltering = true
        do {
            try await Task {
                servers = try await providerManager.filteredServers(with: filters)
                filtersViewModel.update(with: servers)
                isFiltering = false
            }.value
        } catch {
            pp_log(.app, .error, "Unable to fetch filtered servers: \(error)")
        }
    }

    func compatiblePresets(with server: ProviderServer) -> [ProviderPreset<Template>] {
        providerManager
            .presets
            .filter {
                if let selectedId = filtersViewModel.filters.presetId {
                    return $0.presetId == selectedId
                }
                return true
            }
            .filter {
                if let supportedIds = server.metadata.supportedPresetIds {
                    return supportedIds.contains($0.presetId)
                }
                return true
            }
    }

    func onNewFilters(_ filters: ProviderFilters) {
        Task {
            await reloadServers(filters: filters)
        }
    }

    func onToggleFavorites(_ only: Bool) {
        onlyShowsFavorites = only
    }

    func onDisappear() {
        do {
            try providerPreferences.save()
        } catch {
            pp_log(.app, .error, "Unable to save preferences: \(error)")
        }
    }

    func onSelectServer(_ server: ProviderServer, heuristic: ProviderHeuristic?) {
        let presets = compatiblePresets(with: server)
        guard let preset = presets.first else {
            pp_log(.app, .error, "Unable to find a compatible preset. Supported IDs: \(server.metadata.supportedPresetIds ?? [])")
            assertionFailure("No compatible presets for server \(server.serverId) (provider=\(providerManager.providerId), template=\(Template.configurationIdentifier), supported=\(server.metadata.supportedPresetIds ?? []))")
            return
        }
        onSelect(server, heuristic, preset)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProviderServerView(
            moduleId: UUID(),
            providerId: .protonvpn,
            selectedEntity: nil as ProviderEntity<OpenVPNProviderTemplate>?,
            filtersWithSelection: false,
            selectTitle: "Select",
            onSelect: { _, _, _ in }
        )
    }
    .withMockEnvironment()
}
