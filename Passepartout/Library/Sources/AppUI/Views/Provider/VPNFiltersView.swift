//
//  VPNFiltersView.swift
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

import AppLibrary
import CommonLibrary
import PassepartoutKit
import SwiftUI

struct VPNFiltersView<Configuration>: View where Configuration: ProviderConfigurationIdentifiable & Decodable {

    @ObservedObject
    var manager: VPNProviderManager<Configuration>

    @Binding
    var filters: VPNFilters

    @Binding
    var onlyShowsFavorites: Bool

    let favorites: Set<String>

    var body: some View {
        debugChanges()
        return Subview(
            filters: $filters,
            onlyShowsFavorites: $onlyShowsFavorites,
            categories: categories,
            countries: countries,
            presets: presets,
            favorites: favorites
        )
        .onChange(of: filters, perform: manager.applyFilters)
        .onChange(of: onlyShowsFavorites) {
            filters.serverIds = $0 ? favorites : nil
            manager.applyFilters(filters)
        }
    }
}

private extension VPNFiltersView {
    var categories: [String] {
        manager
            .allCategoryNames
            .sorted()
    }

    var countries: [(code: String, description: String)] {
        manager
            .allCountryCodes
            .map {
                (code: $0, description: $0.localizedAsRegionCode ?? $0)
            }
            .sorted {
                $0.description < $1.description
            }
    }

    var presets: [VPNPreset<Configuration>] {
        manager
            .presets
            .sorted {
                $0.description < $1.description
            }
    }
}

// MARK: -

private extension VPNFiltersView {
    struct Subview: View {

        @Binding
        var filters: VPNFilters

        @Binding
        var onlyShowsFavorites: Bool

        let categories: [String]

        let countries: [(code: String, description: String)]

        let presets: [VPNPreset<Configuration>]

        let favorites: Set<String>?

        var body: some View {
            debugChanges()
            return Form {
                Section {
                    categoryPicker
                    countryPicker
                    presetPicker
                    favoritesToggle
#if os(iOS)
                    clearFiltersButton
                        .frame(maxWidth: .infinity, alignment: .center)
#else
                    HStack {
                        Spacer()
                        clearFiltersButton
                    }
#endif
                }
            }
        }
    }
}

private extension VPNFiltersView.Subview {
    var categoryPicker: some View {
        Picker(Strings.Global.category, selection: $filters.categoryName) {
            Text(Strings.Global.any)
                .tag(nil as String?)
            ForEach(categories, id: \.self) {
                Text($0.capitalized)
                    .tag($0 as String?)
            }
        }
    }

    var countryPicker: some View {
        Picker(Strings.Global.country, selection: $filters.countryCode) {
            Text(Strings.Global.any)
                .tag(nil as String?)
            ForEach(countries, id: \.code) {
                Text($0.description)
                    .tag($0.code as String?)
            }
        }
    }

    var presetPicker: some View {
        Picker(Strings.Providers.Vpn.preset, selection: $filters.presetId) {
            Text(Strings.Global.any)
                .tag(nil as String?)
            ForEach(presets, id: \.presetId) {
                Text($0.description)
                    .tag($0.presetId as String?)
            }
        }
    }

    var favoritesToggle: some View {
        Toggle(Strings.Providers.onlyFavorites, isOn: $onlyShowsFavorites)
    }

    var clearFiltersButton: some View {
        Button(Strings.Providers.clearFilters, role: .destructive) {
            onlyShowsFavorites = false
            filters = VPNFilters()
        }
    }
}

#Preview {
    NavigationStack {
        VPNFiltersView<OpenVPN.Configuration>(
            manager: VPNProviderManager(),
            filters: .constant(VPNFilters()),
            onlyShowsFavorites: .constant(false),
            favorites: []
        )
    }
}
