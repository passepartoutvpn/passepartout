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
    struct Subview: View {

        @ObservedObject
        var manager: VPNProviderManager<Configuration>

        let selectedServer: VPNServer?

        @Binding
        var filters: VPNFilters

        let onSelect: (VPNServer) -> Void

        var body: some View {
            VStack {
                filtersView
                tableView
            }
        }
    }
}

private extension VPNProviderServerView.Subview {
    var tableView: some View {
        Table(manager.filteredServers) {
            TableColumn("") { server in
                ThemeImage(.marked)
                    .opacity(server.id == selectedServer?.id ? 1.0 : 0.0)
            }
            .width(max: 20.0)

            TableColumn(Strings.Global.region) { server in
                HStack {
                    ThemeCountryFlag(code: server.provider.countryCode)
                    Text(server.region)
                }
            }
            .width(max: 200.0)

            TableColumn(Strings.Global.address, value: \.address)

            TableColumn("") { server in
                Button {
                    onSelect(server)
                } label: {
                    Text(Strings.Views.Provider.selectServer)
                }
            }
            .width(min: 100.0, max: 100.0)
        }
        .disabled(manager.isFiltering)
    }

    var filtersView: some View {
        VPNFiltersView(
            manager: manager,
            filters: $filters
        )
        .padding()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VPNProviderServerView(
            apis: [API.bundled],
            providerId: .tunnelbear,
            configurationType: OpenVPN.Configuration.self,
            selectedEntity: nil,
            filtersWithSelection: false,
            onSelect: { _, _ in }
        )
    }
    .withMockEnvironment()
}

#endif
