//
//  VPNProviderServerView+iOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/9/24.
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

#if os(iOS)

import PassepartoutKit
import SwiftUI

extension VPNProviderServerView {
    struct Subview: View {

        @ObservedObject
        var manager: VPNProviderManager<Configuration>

        let selectedServer: VPNServer?

        @Binding
        var filters: VPNFilters

        @Binding
        var onlyShowsFavorites: Bool

        @Binding
        var favorites: Set<String>

        // unused
        let selectTitle: String

        let onSelect: (VPNServer) -> Void

        @State
        private var isFiltersPresented = false

        var body: some View {
            listView
                .disabled(manager.isFiltering)
                .toolbar {
                    filtersItem
                }
        }
    }
}

private extension VPNProviderServerView.Subview {
    var listView: some View {
        ZStack {
            if manager.isFiltering {
                ProgressView()
            } else if !manager.filteredServers.isEmpty {
                List {
                    Section {
                        ForEach(countryCodes, id: \.self, content: countryView)
                    } header: {
                        Text(filters.categoryName ?? Strings.Providers.Vpn.Category.any)
                    }
                }
            } else {
                Text(Strings.Providers.Vpn.noServers)
                    .themeEmptyMessage()
            }
        }
        .themeAnimation(on: manager.isFiltering, category: .providers)
    }

    var countryCodes: [String] {
        manager
            .allCountryCodes
            .sorted {
                guard let region1 = $0.localizedAsRegionCode,
                      let region2 = $1.localizedAsRegionCode else {
                    return $0 < $1
                }
                return region1 < region2
            }
    }

    func countryServers(for code: String) -> [VPNServer]? {
        manager
            .filteredServers
            .filter {
                $0.provider.countryCode == code
            }
            .nilIfEmpty
    }

    func countryView(for code: String) -> some View {
        countryServers(for: code)
            .map { servers in
                DisclosureGroup {
                    ForEach(servers, id: \.id, content: serverView)
                } label: {
                    HStack {
                        ThemeCountryFlag(code: code)
                        Text(code.localizedAsRegionCode ?? code)
                    }
                }
            }
    }

    func serverView(for server: VPNServer) -> some View {
        Button {
            onSelect(server)
        } label: {
            HStack {
                ThemeImage(.marked)
                    .opacity(server.id == selectedServer?.id ? 1.0 : 0.0)
                VStack(alignment: .leading) {
                    if let area = server.provider.area {
                        Text(area)
                            .font(.headline)
                        Text(server.provider.serverId)
                            .font(.subheadline)
                    } else {
                        Text(server.provider.serverId)
                            .font(.headline)
                    }
                }
                Spacer()
                FavoriteToggle(value: server.serverId, selection: $favorites)
            }
        }
    }

    var filtersItem: some ToolbarContent {
        ToolbarItem {
            Button {
                isFiltersPresented = true
            } label: {
                ThemeImage(.filters)
            }
            .themePopover(isPresented: $isFiltersPresented, content: filtersView)
        }
    }

    func filtersView() -> some View {
        NavigationStack {
            VPNFiltersView(
                manager: manager,
                filters: $filters,
                onlyShowsFavorites: $onlyShowsFavorites,
                favorites: favorites
            )
            .navigationTitle(Strings.Global.filters)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VPNProviderServerView(
            apis: [API.bundled],
            moduleId: UUID(),
            providerId: .tunnelbear,
            configurationType: OpenVPN.Configuration.self,
            selectedEntity: nil,
            filtersWithSelection: false,
            selectTitle: "Select",
            onSelect: { _, _ in }
        )
    }
    .withMockEnvironment()
}

#endif
