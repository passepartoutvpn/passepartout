//
//  VPNProviderServer+Content+iOS.swift
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

import CommonAPI
import CommonLibrary
import PassepartoutKit
import SwiftUI

extension VPNProviderServerView {
    struct ContentView: View {
        let apis: [APIMapper]

        let providerId: ProviderID

        let servers: [VPNServer]

        let selectedServer: VPNServer?

        let isFiltering: Bool

        @ObservedObject
        var filtersViewModel: VPNFiltersView.Model

        @ObservedObject
        var favoritesManager: ProviderFavoritesManager

        let selectTitle: String

        let onSelect: (VPNServer) -> Void

        @State
        private var serversByCountryCode: [String: [VPNServer]] = [:]

        @State
        private var expandedCodes: Set<String> = []

        var body: some View {
            debugChanges()
            return listView
                .themeAnimation(on: isFiltering, category: .providers)
                .onChange(of: servers, perform: computeServersByCountry)
        }
    }
}

private extension VPNProviderServerView.ContentView {
    var listView: some View {
        List {
            Section {
                Toggle(Strings.Views.Providers.onlyFavorites, isOn: $filtersViewModel.onlyShowsFavorites)
                RefreshInfrastructureButton(apis: apis, providerId: providerId)
            }
            Group {
                if isFiltering || !servers.isEmpty {
                    if isFiltering {
                        ProgressView()
                            .id(UUID())
                    } else {
                        ForEach(countryCodes, id: \.self, content: countryView)
                    }
                } else {
                    emptyView
                }
            }
            .themeSection(
                header: filtersViewModel.filters.categoryName ?? Strings.Views.Vpn.Category.any
            )
            .onLoad {
                if let selectedServer = selectedServer {
                    expandedCodes.insert(selectedServer.provider.countryCode)
                }
            }
        }
    }

    var emptyView: some View {
        Text(Strings.Views.Vpn.noServers)
    }
}

private extension VPNProviderServerView.ContentView {
    var countryCodes: [String] {
        filtersViewModel
            .countries
            .map(\.code)
    }

    func isExpandedCountry(_ code: String) -> Binding<Bool> {
        Binding {
            expandedCodes.contains(code)
        } set: {
            if $0 {
                expandedCodes.insert(code)
            } else {
                expandedCodes.remove(code)
            }
        }
    }

    func countryView(for code: String) -> some View {
        serversByCountryCode[code]
            .map { servers in
                DisclosureGroup(isExpanded: isExpandedCountry(code)) {
                    ForEach(servers, id: \.id, content: serverView)
                } label: {
                    ThemeCountryText(code)
                }
            }
    }

    func serverView(for server: VPNServer) -> some View {
        Button {
            onSelect(server)
        } label: {
            HStack {
                ThemeImage(.marked)
                    .opaque(server.id == selectedServer?.id)
                VStack(alignment: .leading) {
                    if let area = server.provider.area {
                        Text(area)
                            .font(.headline)
                    }
                    Text(server.hostname ?? server.serverId)
                        .font(.subheadline)
                        .truncationMode(.middle)
                }
                Spacer()
                FavoriteToggle(
                    value: server.serverId,
                    selection: $favoritesManager.serverIds
                )
            }
        }
    }

    func computeServersByCountry(_ servers: [VPNServer]) {
        var map: [String: [VPNServer]] = [:]
        servers.forEach {
            let code = $0.provider.countryCode
            var list = map[code] ?? []
            list.append($0)
            map[code] = list
        }
        withAnimation {
            serversByCountryCode = map
        }
    }
}

#endif
