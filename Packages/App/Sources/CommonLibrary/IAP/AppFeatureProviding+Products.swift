//
//  AppFeatureProviding+Products.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/20/24.
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

import Foundation

extension AppProduct: AppFeatureProviding {
    public var features: [AppFeature] {
        switch self {

        // MARK: Current

        case .Essentials.allPlatforms:
            return AppFeature.essentialFeatures

        case .Essentials.iOS:
#if os(iOS) || os(tvOS)
            return AppProduct.Essentials.allPlatforms.features
#else
            return []
#endif

        case .Essentials.macOS:
#if os(macOS) || os(tvOS)
            return AppProduct.Essentials.allPlatforms.features
#else
            return []
#endif

        case .Features.appleTV:
            var eligible: [AppFeature] = [.appleTV, .sharing]
#if os(tvOS)
            // include "Essentials" to cope with BuildProducts
            // limitations
            //
            // some old iOS users are acknowledged certain
            // purchases based on the build number of their first
            // download, e.g. "Essentials iOS". unfortunately,
            // that build number is not the same on tvOS, so
            // those purchases do not exist and the TV may complain
            // about missing features other than .appleTV
            //
            // we avoid this by relying on iOS/macOS eligibility
            // alone while only requiring .appleTV on tvOS
            //
            // this is a solid workaround as long as profiles are
            // not editable on tvOS
            eligible.append(contentsOf: AppProduct.Essentials.allPlatforms.features)
#endif
            return eligible

        // MARK: Discontinued

        case .Full.OneTime.lifetime, .Full.Recurring.monthly, .Full.Recurring.yearly:
            return AppFeature.allCases

        case .Features.allProviders:
            return [.providers]

        case .Features.networkSettings:
            return [.dns, .httpProxy, .routing]

        case .Features.trustedNetworks:
            return [.onDemand]

        default:
            return []
        }
    }
}
