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

        @Binding
        var filters: VPNFilters

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
        List {
            // FIXME: #746, providers UI, iOS server rows + country flags
            if manager.isFiltering {
                ProgressView()
            } else {
                ForEach(manager.filteredServers, id: \.id) { server in
                    Button("\(server.hostname ?? server.id) \(server.provider.countryCode)") {
                        onSelect(server)
                    }
                }
            }
        }
        .themeAnimation(on: manager.isFiltering, category: .providers)
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
                filters: $filters
            )
            .navigationTitle(Strings.Global.filters)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

#endif
