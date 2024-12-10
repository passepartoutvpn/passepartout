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

import Combine
import CommonLibrary
import PassepartoutKit
import SwiftUI

struct VPNFiltersView: View {
    let apis: [APIMapper]

    let providerId: ProviderID

    @ObservedObject
    var model: Model

    var body: some View {
        debugChanges()
        return Form {
            Section {
                categoryPicker
                countryPicker
                presetPicker
#if os(iOS)
                clearFiltersButton
                    .frame(maxWidth: .infinity, alignment: .center)
#else
                HStack {
                    favoritesToggle
                    Spacer()
                    RefreshInfrastructureButton(apis: apis, providerId: providerId)
                    clearFiltersButton
                }
#endif
            }
        }
    }
}

private extension VPNFiltersView {
    var categoryNameBinding: Binding<String?> {
        Binding {
            model.filters.categoryName
        } set: {
            model.filters.categoryName = $0
            model.filters.countryCode = nil
        }
    }

    var categoryPicker: some View {
        Picker(Strings.Global.Nouns.category, selection: categoryNameBinding) {
            Text(Strings.Global.Nouns.any)
                .tag(nil as String?)
            ForEach(model.categories, id: \.self) {
                Text($0.capitalized)
                    .tag($0 as String?)
            }
        }
    }

    var countryPicker: some View {
        Picker(Strings.Global.Nouns.country, selection: $model.filters.countryCode) {
            Text(Strings.Global.Nouns.any)
                .tag(nil as String?)
            ForEach(model.countries, id: \.code) {
                ThemeCountryText($0.code, title: $0.description)
                    .tag($0.code as String?)
            }
        }
    }

    var presetPicker: some View {
        Picker(Strings.Views.Vpn.preset, selection: $model.filters.presetId) {
            ForEach(model.presets, id: \.presetId) {
                Text($0.description)
                    .tag($0.presetId as String?)
            }
        }
    }

    var favoritesToggle: some View {
        Toggle(Strings.Views.Providers.onlyFavorites, isOn: $model.onlyShowsFavorites)
    }

    var clearFiltersButton: some View {
        Button(Strings.Views.Providers.clearFilters, role: .destructive) {
            model.filters = VPNFilters()
        }
    }
}

#Preview {
    NavigationStack {
        VPNFiltersView(
            apis: [API.bundled],
            providerId: .mullvad,
            model: .init()
        )
    }
}
