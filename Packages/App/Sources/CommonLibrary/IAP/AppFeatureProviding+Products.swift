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

        case .Essentials.iOS_macOS:
            return AppFeature.essentialFeatures

        case .Essentials.iOS:
#if os(iOS) || os(tvOS)
            return AppProduct.Essentials.iOS_macOS.features
#else
            return []
#endif

        case .Essentials.macOS:
#if os(macOS) || os(tvOS)
            return AppProduct.Essentials.iOS_macOS.features
#else
            return []
#endif

        case .Features.appleTV:

            //
            // some old iOS users were acknowledged certain
            // purchases, e.g. "Essentials iOS", based on the build
            // number of their first download, because the app used
            // to be paid rather than freemium in the past. those
            // conditions appeared in Dependencies.productsAtBuild()
            //
            // unfortunately, the build number is not unique across
            // platforms, so those features artificially made available
            // on iOS via the build number were not eligible on other
            // platforms. this led the tvOS app to complain about
            // unpaid features
            //
            // now that .productsAtBuild() uses the original purchase
            // date as condition, which is cross-platform, there should
            // be no need for workarounds. those old iOS purchasers
            // should now see their artificial in-app purchase propagated
            // to the tvOS app
            //
            var eligible: [AppFeature] = [.appleTV, .sharing]
#if os(tvOS)
            eligible.append(contentsOf: AppFeature.essentialFeatures)
#endif
            return eligible

        case .Complete.OneTime.lifetime, .Complete.Recurring.monthly, .Complete.Recurring.yearly:
            return AppFeature.allCases

        // MARK: Discontinued

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
