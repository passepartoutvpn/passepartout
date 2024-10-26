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
        private(set) var categories: [String]

        private(set) var countries: [(code: String, description: String)]

        private(set) var presets: [AnyVPNPreset]

        @Published
        var filters = VPNFilters()

        @Published
        var onlyShowsFavorites = false

        let filtersDidChange = PassthroughSubject<VPNFilters, Never>()

        let onlyShowsFavoritesDidChange = PassthroughSubject<Bool, Never>()

        init(
            categories: [String] = [],
            countries: [(code: String, description: String)] = [],
            presets: [AnyVPNPreset] = []
        ) {
            self.categories = categories
            self.countries = countries
            self.presets = presets
        }

        func load<C>(
            with vpnManager: VPNProviderManager<C>,
            initialFilters: VPNFilters?
        ) where C: ProviderConfigurationIdentifiable {
            categories = vpnManager
                .allCategoryNames
                .sorted()

            countries = vpnManager
                .allCountryCodes
                .map {
                    (code: $0, description: $0.localizedAsRegionCode ?? $0)
                }
                .sorted {
                    $0.description < $1.description
                }

            presets = vpnManager
                .allPresets
                .values
                .filter {
                    $0.configurationIdentifier == C.providerConfigurationIdentifier
                }
                .sorted {
                    $0.description < $1.description
                }

            if let initialFilters {
                filters = initialFilters
            }

            objectWillChange.send()
        }
    }
}
