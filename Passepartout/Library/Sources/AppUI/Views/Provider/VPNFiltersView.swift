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
import PassepartoutKit
import SwiftUI

// FIXME: #703, providers UI

struct VPNFiltersView<Configuration>: View where Configuration: Decodable {

    @ObservedObject
    var manager: VPNProviderManager

    @State
    private var isRefreshing = false

    var body: some View {
        Form {
            Section {
                categoryPicker
                countryPicker
                presetPicker
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

private extension VPNFiltersView {
    var categoryPicker: some View {
        Picker("Category", selection: $manager.parameters.filters.categoryName) {
            Text("Any")
                .tag(nil as String?)
            ForEach(categories, id: \.self) {
                Text($0.capitalized)
                    .tag($0 as String?)
            }
        }
    }

    var countryPicker: some View {
        Picker("Country", selection: $manager.parameters.filters.countryCode) {
            Text("Any")
                .tag(nil as String?)
            ForEach(countries, id: \.code) {
                Text($0.description)
                    .tag($0.code as String?)
            }
        }
    }

    @ViewBuilder
    var presetPicker: some View {
        if manager.allPresets.count > 1 {
            Picker("Preset", selection: $manager.parameters.filters.presetId) {
                Text("Any")
                    .tag(nil as String?)
                ForEach(presets, id: \.presetId) {
                    Text($0.description)
                        .tag($0.presetId as String?)
                }
            }
        }
    }

    var clearFiltersButton: some View {
        Button("Clear filters", role: .destructive) {
            manager.resetFilters()
        }
    }
}

private extension VPNFiltersView {
    var categories: [String] {
        let allCategories = manager
            .allServers
            .values
            .map(\.provider.categoryName)

        return Set(allCategories)
            .sorted()
    }

    var countries: [(code: String, description: String)] {
        let allCodes = manager
            .allServers
            .values
            .flatMap(\.provider.countryCodes)

        return Set(allCodes)
            .map {
                (code: $0, description: $0.localizedAsRegionCode ?? $0)
            }
            .sorted {
                $0.description < $1.description
            }
    }

    var presets: [VPNPreset<Configuration>] {
        manager
            .presets(ofType: Configuration.self)
            .sorted {
                $0.description < $1.description
            }
    }
}

#Preview {
    NavigationStack {
        VPNFiltersView<String>(manager: VPNProviderManager())
    }
}
