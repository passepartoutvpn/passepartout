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
import PassepartoutKit
import SwiftUI

extension ProviderServerView {
    struct ContentView: View {

        @EnvironmentObject
        private var theme: Theme

        let apis: [APIMapper]

        let providerId: ProviderID

        let servers: [ProviderServer]

        let selectedServer: ProviderServer?

        let isFiltering: Bool

        @ObservedObject
        var filtersViewModel: ProviderFiltersView.Model

        @ObservedObject
        var providerPreferences: ProviderPreferences

        let selectTitle: String

        let onSelect: (ProviderServer) -> Void

        @State
        private var hoveringServerId: String?

        var body: some View {
            debugChanges()
            return tableView
        }
    }
}

private extension ProviderServerView.ContentView {
    var tableView: some View {
        Table(servers) {
            TableColumn("") { server in
                ThemeImage(.marked)
                    .opaque(server.id == selectedServer?.id)
                    .environmentObject(theme) // TODO: #873, Table loses environment
            }
            .width(10.0)

            TableColumn("☆") { server in
                FavoriteToggle(
                    value: server.serverId,
                    selection: providerPreferences.favoriteServers()
                )
                .environmentObject(theme) // TODO: #873, Table loses environment
            }
            .width(15.0)

            TableColumn(Strings.Global.Nouns.region) { server in
                Button {
                    onSelect(server)
                } label: {
                    ThemeCountryText(server.metadata.countryCode, title: server.region)
                }
                .help(server.region)
                .cursor(.hand)
                .environmentObject(theme) // TODO: #873, Table loses environment
            }

            TableColumn(Strings.Global.Nouns.address) { server in
                Button {
                    onSelect(server)
                } label: {
                    Text(server.address)
                }
                .cursor(.hand)
            }
            .width(min: 300.0)
        }
    }
}

#endif
