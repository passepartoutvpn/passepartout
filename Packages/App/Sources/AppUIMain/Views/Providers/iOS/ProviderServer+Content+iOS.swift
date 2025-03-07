//
//  ProviderServer+Content+iOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/9/24.
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

#if os(iOS)

import CommonAPI
import CommonLibrary
import PassepartoutKit
import SwiftUI
import UIAccessibility

extension ProviderServerView {
    struct ContentView: View {
        let providerId: ProviderID

        let servers: [ProviderServer]

        let selectedServer: ProviderServer?

        @Binding
        var heuristic: ProviderHeuristic?

        let isFiltering: Bool

        @ObservedObject
        var filtersViewModel: ProviderFiltersView.Model

        @ObservedObject
        var providerPreferences: ProviderPreferences

        let selectTitle: String

        let onSelect: (ProviderServer, ProviderHeuristic?) -> Void

        @State
        private var regionsByCountryCode: [String: [ProviderRegion]] = [:]

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

private extension ProviderServerView.ContentView {
    var listView: some View {
        List {
            Section {
                Toggle(Strings.Views.Providers.onlyFavorites, isOn: $filtersViewModel.onlyShowsFavorites)
                RefreshInfrastructureButton(providerId: providerId)
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
                if let selectedServer {
                    expandedCodes.insert(selectedServer.metadata.countryCode)
                }
            }
        }
    }

    func countryView(for code: String) -> some View {
        regionsByCountryCode[code]
            .map { regions in
                Group {
                    if regions.count > 1 {
                        DisclosureGroup(isExpanded: isExpandedCountry(code)) {
                            ForEach(regions, id: \.id, content: regionView)
                        } label: {
                            ThemeCountryText(code)
                        }
                        .uiAccessibility(.ProviderServers.countryGroup)
                    } else if let singleRegion = regions.first {
                        regionView(for: singleRegion, isSingle: true)
                    }
                }
            }
    }

    func regionView(for region: ProviderRegion) -> some View {
        regionView(for: region, isSingle: false)
    }

    func regionView(for region: ProviderRegion, isSingle: Bool) -> some View {
        Button {
            let heuristic: ProviderHeuristic
            if !isSingle && region.area != nil {
                heuristic = .sameRegion(region)
            } else {
                heuristic = .sameCountry(region.countryCode)
            }
            guard let randomServer = servers.randomServer(using: heuristic) else {
                return
            }
            onSelect(randomServer, heuristic)
        } label: {
            if !isSingle && region.area == nil {
                HStack {
                    ThemeImage(.marked)
                        .opaque(region.isSelected(by: heuristic))
                    Text(Strings.Global.Nouns.any)
                }
            } else {
                HStack {
                    ThemeImage(.marked)
                        .opaque(region.isSelected(by: heuristic))
                    if isSingle {
                        ThemeCountryText(region.countryCode, title: region.localizedDescription)
                    } else if let area = region.area {
                        Text(area)
                    }
                    Spacer()
                    FavoriteToggle(
                        value: region.id,
                        selection: providerPreferences.favoriteServers()
                    )
                }
            }
        }
        .foregroundStyle(.primary)
    }

    var emptyView: some View {
        Text(Strings.Views.Vpn.noServers)
    }
}

private extension ProviderServerView.ContentView {
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

    // FIXME: #1231, servers.regions is inefficient, fetch regions directly
    func computeServersByCountry(_ servers: [ProviderServer]) {
        let regions = servers.regions
        var map: [String: [ProviderRegion]] = [:]
        regions.forEach {
            let code = $0.countryCode
            var list = map[code] ?? []
            list.append($0)
            map[code] = list
        }
        regionsByCountryCode = map
    }
}

#endif
