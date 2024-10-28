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
        let servers: [VPNServer]

        let selectedServerId: String?

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
                        .opacity(server.id == selectedServerId ? 1.0 : 0.0)
                }
                .width(10.0)

                TableColumn(Strings.Global.region) { server in
                    HStack {
                        ThemeCountryFlag(code: server.provider.countryCode)
                        Text(server.region)
                            .help(server.region)
                    }
                }

                TableColumn(Strings.Global.address, value: \.address)

                TableColumn("􀋂") { server in
                    FavoriteToggle(
                        value: server.serverId,
                        selection: $favoritesManager.serverIds
                    )
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
