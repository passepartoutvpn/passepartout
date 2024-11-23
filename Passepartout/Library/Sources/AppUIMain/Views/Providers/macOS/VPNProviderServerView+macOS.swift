//
//  VPNProviderServerView+macOS.swift
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

#if os(macOS)

import CommonAPI
import CommonLibrary
import PassepartoutKit
import SwiftUI

extension VPNProviderServerView {
    var contentView: some View {
        VStack {
            filtersView
                .padding()
            serversView
        }
    }
}

// MARK: - Subviews

extension VPNProviderServerView {
    struct ServersSubview: View {

        @EnvironmentObject
        private var theme: Theme

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
        private var hoveringServerId: String?

        var body: some View {
            debugChanges()
            return Table(servers) {
                TableColumn("") { server in
                    ThemeImage(.marked)
                        .opaque(server.id == selectedServer?.id)
                        .environmentObject(theme) // TODO: #873, Table loses environment
                }
                .width(10.0)

                TableColumn(Strings.Global.Nouns.region) { server in
                    ThemeCountryText(server.provider.countryCode, title: server.region)
                        .help(server.region)
                        .environmentObject(theme) // TODO: #873, Table loses environment
                }

                TableColumn(Strings.Global.Nouns.address, value: \.address)

                TableColumn("􀋂") { server in
                    FavoriteToggle(
                        value: server.serverId,
                        selection: $favoritesManager.serverIds
                    )
                    .environmentObject(theme) // TODO: #873, Table loses environment
                }
                .width(15.0)

                TableColumn("") { server in
                    Button {
                        onSelect(server)
                    } label: {
                        Text(selectTitle)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
        }
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
