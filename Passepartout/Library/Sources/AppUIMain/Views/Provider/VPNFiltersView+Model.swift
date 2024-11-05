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
import CommonLibrary
import Foundation
import PassepartoutKit

extension VPNFiltersView {

    @MainActor
    final class Model: ObservableObject {
        typealias CodeWithDescription = (code: String, description: String)

        private let defaults: UserDefaults

        private var options: VPNFilterOptions

        @Published
        private(set) var categories: [String]

        @Published
        private(set) var countries: [CodeWithDescription]

        @Published
        private(set) var presets: [AnyVPNPreset]

        @Published
        var filters: VPNFilters

        @Published
        var onlyShowsFavorites: Bool

        let filtersDidChange: PassthroughSubject<VPNFilters, Never>

        let onlyShowsFavoritesDidChange: PassthroughSubject<Bool, Never>

        private var subscriptions: Set<AnyCancellable>

        init(defaults: UserDefaults = .standard) {
            self.defaults = defaults
            options = VPNFilterOptions()
            categories = []
            countries = []
            presets = []
            filters = VPNFilters()
            onlyShowsFavorites = false
            filtersDidChange = PassthroughSubject()
            onlyShowsFavoritesDidChange = PassthroughSubject()
            subscriptions = []

            observeObjects()
        }

        func load(options: VPNFilterOptions, initialFilters: VPNFilters?) {
            self.options = options
            setCategories(withNames: Set(options.countriesByCategoryName.keys))
            setCountries(withCodes: options.countryCodes)
            setPresets(with: options.presets)

            if let initialFilters {
                filters = initialFilters
            }
        }

        func update(with servers: [VPNServer]) {

            // only countries that have servers in this category
            let knownCountryCodes: Set<String>
            if let categoryName = filters.categoryName {
                knownCountryCodes = options.countriesByCategoryName[categoryName] ?? []
            } else {
                knownCountryCodes = options.countryCodes
            }

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
            .map(\.asCountryCodeWithDescription)
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

// MARK: - Observation

private extension VPNFiltersView.Model {
    func observeObjects() {
        $filters
            .sink { [weak self] in
                self?.filtersDidChange.send($0)
            }
            .store(in: &subscriptions)

        $onlyShowsFavorites
            .dropFirst()
            .sink { [weak self] in
                self?.defaults.onlyShowsFavorites = $0
                self?.onlyShowsFavoritesDidChange.send($0)
            }
            .store(in: &subscriptions)

        // send initial value
        onlyShowsFavorites = defaults.onlyShowsFavorites
    }
}

// MARK: -

private extension UserDefaults {
    var onlyShowsFavorites: Bool {
        get {
            bool(forKey: AppPreference.onlyShowsFavorites.key)
        }
        set {
            set(newValue, forKey: AppPreference.onlyShowsFavorites.key)
        }
    }
}

private extension String {
    var asCountryCodeWithDescription: VPNFiltersView.Model.CodeWithDescription {
        (self, localizedAsRegionCode ?? self)
    }
}
