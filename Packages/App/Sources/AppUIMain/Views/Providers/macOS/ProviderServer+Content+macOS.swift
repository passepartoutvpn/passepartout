//
//  ProviderServer+Content+macOS.swift
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

#if os(macOS)

import CommonAPI
import CommonLibrary
import SwiftUI

extension ProviderServerView {
    struct ContentView: View {

        @EnvironmentObject
        private var theme: Theme

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
        private var hoveringServerId: String?

        var body: some View {
            debugChanges()
            return serversTable
        }
    }
}

private extension ProviderServerView.ContentView {
    var serversTable: some View {
        // TODO: #1263, servers.regions is inefficient, fetch regions directly
        Table(servers.regions) {
            TableColumn("") { region in
                ThemeImage(.marked)
                    .opaque(region.isSelected(by: heuristic))
                    .environmentObject(theme) // TODO: #873, Table loses environment
            }
            .width(10.0)

            TableColumn("☆") { region in
                ThemeFavoriteToggle(
                    value: region.id,
                    selection: providerPreferences.favoriteServers()
                )
                .environmentObject(theme) // TODO: #873, Table loses environment
            }
            .width(15.0)

            TableColumn(Strings.Global.Nouns.country) { region in
                Button {
                    let heuristic: ProviderHeuristic
                    if region.area != nil {
                        heuristic = .sameRegion(region)
                    } else {
                        heuristic = .sameCountry(region.countryCode)
                    }
                    guard let randomServer = servers.randomServer(using: heuristic) else {
                        return
                    }
                    onSelect(randomServer, heuristic)
                } label: {
                    ThemeCountryText(region.countryCode)
                }
                .help(region.localizedDescription)
                .cursor(.hand)
                .environmentObject(theme) // TODO: #873, Table loses environment
            }

            TableColumn(Strings.Global.Nouns.region) { region in
                Button {
                    let heuristic: ProviderHeuristic = .sameRegion(region)
                    guard let randomServer = servers.randomServer(using: heuristic) else {
                        return
                    }
                    onSelect(randomServer, heuristic)
                } label: {
                    region.area.map(Text.init)
                }
                .help(region.area ?? "")
                .cursor(.hand)
                .environmentObject(theme) // TODO: #873, Table loses environment
            }
        }
    }
}

#endif
