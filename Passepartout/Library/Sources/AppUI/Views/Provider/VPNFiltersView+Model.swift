//
//  VPNFiltersView+Model.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/26/24.
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
import Foundation
import PassepartoutKit

extension VPNFiltersView {

    @MainActor
    final class Model: ObservableObject {
        typealias LocalizedCountry = (code: String, description: String)

        private var options: VPNFilterOptions

        @Published
        private(set) var categories: [String]

        @Published
        private(set) var countries: [LocalizedCountry]

        @Published
        private(set) var presets: [AnyVPNPreset]

        @Published
        var filters = VPNFilters()

        @Published
        var onlyShowsFavorites = false

        let filtersDidChange = PassthroughSubject<VPNFilters, Never>()

        let onlyShowsFavoritesDidChange = PassthroughSubject<Bool, Never>()

        init() {
            options = VPNFilterOptions()
            categories = []
            countries = []
            presets = []
        }

        func load(options: VPNFilterOptions, initialFilters: VPNFilters?) {
            self.options = options
            setCategories(withNames: options.categoryNames)
            setCountries(withCodes: options.countryCodes)
            setPresets(with: options.presets)

            if let initialFilters {
                filters = initialFilters
            }
        }

        func update(with servers: [VPNServer]) {

            // only non-empty countries
            let knownCountryCodes = Set(servers.map(\.provider.countryCode))

            // only presets known in filtered servers
            var knownPresets = options.presets
            let allPresetIds = Set(servers.compactMap(\.provider.supportedPresetIds).joined())
            if !allPresetIds.isEmpty {
                knownPresets = knownPresets
                    .filter {
                        allPresetIds.contains($0.presetId)
                    }
            }

            setCountries(withCodes: knownCountryCodes)
            setPresets(with: knownPresets)
        }
    }
}

private extension VPNFiltersView.Model {
    func setCategories(withNames categoryNames: Set<String>) {
        categories = categoryNames
            .sorted()
    }

    func setCountries(withCodes codes: Set<String>) {
        countries = codes
            .map(\.asLocalizedCountry)
            .sorted {
                $0.description < $1.description
            }
    }

    func setPresets(with presets: Set<AnyVPNPreset>) {
        self.presets = presets
            .sorted {
                $0.description < $1.description
            }
    }
}

private extension String {
    var asLocalizedCountry: VPNFiltersView.Model.LocalizedCountry {
        (self, localizedAsRegionCode ?? self)
    }
}
