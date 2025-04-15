//
//  ProviderRegion+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/4/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary

extension ProviderServer {
    var region: ProviderRegion {
        ProviderRegion(countryCode: metadata.countryCode, area: metadata.area)
    }
}

extension String {
    func isCountryCodeSelected(by heuristic: ProviderHeuristic?) -> Bool {
        guard let heuristic else {
            return false
        }
        switch heuristic {
        case .exact(let server):
            return self == server.metadata.countryCode
        case .sameCountry(let code):
            return self == code
        case .sameRegion(let region):
            return self == region.countryCode
        }
    }
}

extension ProviderRegion {
    func isSelected(by heuristic: ProviderHeuristic?) -> Bool {
        guard let heuristic else {
            return false
        }
        switch heuristic {
        case .exact(let server):
            return id == server.regionId
        case .sameCountry(let code):
            return countryCode == code && area == nil
        case .sameRegion(let region):
            return id == region.id
        }
    }
}

extension Collection where Element == ProviderServer {

    // FIXME: #1263, drop this later, fetch regions directly from Core Data
    var regions: [ProviderRegion] {
        var list: [ProviderRegion] = []
        var added: Set<String> = []
        forEach {
            let regionId = $0.regionId
            if !added.contains(regionId) {
                added.insert(regionId)
                if $0.metadata.area != nil {
                    let anyRegion = ProviderRegion(countryCode: $0.metadata.countryCode, area: nil)
                    if !added.contains(anyRegion.id) {
                        added.insert(anyRegion.id)
                        list.append(anyRegion)
                    }
                }
                list.append($0.region)
            }
        }
        return list
    }

    func randomServer(using heuristic: ProviderHeuristic) -> ProviderServer? {
        filter(heuristic.matches)
            .randomElement()
    }
}
