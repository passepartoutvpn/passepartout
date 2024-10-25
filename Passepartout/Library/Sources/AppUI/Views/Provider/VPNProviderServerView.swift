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
import CommonLibrary
import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct VPNProviderServerView<Configuration>: View where Configuration: ProviderConfigurationIdentifiable & Codable {

    @EnvironmentObject
    private var providerManager: ProviderManager

    @AppStorage(AppPreference.moduleFavoriteServers.key)
    var allFavorites = ModuleFavoriteServers()

    var apis: [APIMapper] = API.shared

    let moduleId: UUID

    let providerId: ProviderID

    let configurationType: Configuration.Type

    let selectedEntity: VPNEntity<Configuration>?

    let filtersWithSelection: Bool

    let selectTitle: String

    let onSelect: (_ server: VPNServer, _ preset: VPNPreset<Configuration>) -> Void

    @StateObject
    private var manager = VPNProviderManager<Configuration>(sorting: [
        .localizedCountry,
        .area,
        .hostname
    ])

    @State
    private var filters = VPNFilters()

    @State
    private var onlyShowsFavorites = false

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        debugChanges()
        return Subview(
            manager: manager,
            selectedServer: selectedEntity?.server,
            filters: $filters,
            onlyShowsFavorites: $onlyShowsFavorites,
            favorites: allFavorites.servers(forModuleWithID: moduleId),
            selectTitle: selectTitle,
            onSelect: selectServer
        )
        .withErrorHandler(errorHandler)
        .navigationTitle(Strings.Global.servers)
        .themeNavigationDetail()
        .onLoad {
            Task {
                do {
                    manager.repository = try await providerManager.vpnRepository(
                        from: apis,
                        for: providerId
                    )
                    if let selectedEntity, filtersWithSelection {
                        filters = VPNFilters(with: selectedEntity.server.provider)
                    } else {
                        filters = VPNFilters()
                    }
                    manager.applyFilters(filters)
                } catch {
                    pp_log(.app, .error, "Unable to load VPN repository: \(error)")
                    errorHandler.handle(error, title: Strings.Global.servers)
                }
            }
        }
    }
}

// MARK: - Actions

extension VPNProviderServerView {
    func compatiblePreset(with server: VPNServer) -> VPNPreset<Configuration>? {
        manager
            .presets
            .first {
                if let supportedIds = server.provider.supportedPresetIds {
                    return supportedIds.contains($0.presetId)
                }
                return true
            }
    }

    func isFavoriteServer(_ server: VPNServer) -> Bool {
        filters.serverIds?.contains(server.serverId) ?? false
    }

    func selectServer(_ server: VPNServer) {
        guard let preset = compatiblePreset(with: server) else {
            pp_log(.app, .error, "Unable to find a compatible preset. Supported IDs: \(server.provider.supportedPresetIds ?? [])")
            assertionFailure("No compatible presets for server \(server.serverId) (manager=\(manager.providerId), configuration=\(Configuration.providerConfigurationIdentifier), supported=\(server.provider.supportedPresetIds ?? []))")
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
