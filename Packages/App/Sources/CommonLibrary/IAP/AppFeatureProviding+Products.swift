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

        case .Full.OneTime.allFeatures, .Full.Recurring.monthly, .Full.Recurring.yearly:
            return AppFeature.allCases

        case .Features.appleTV:
#if os(tvOS)
            // treat .appleTV as full version on tvOS to cope
            // with BuildProducts limitations
            //
            // some old iOS/macOS users are acknowledged certain
            // purchases based on the build number of their first
            // download, e.g. "Full version (iOS)". unfortunately,
            // that build number is not the same on tvOS, so
            // those purchases do not exist and the TV may complain
            // about missing features other than .appleTV
            //
            // we avoid this by relying on iOS/macOS eligibility
            // alone while only requiring .appleTV on tvOS
            //
            // this is a solid workaround as long as profiles are
            // not editable on tvOS
            return AppFeature.allCases
#else
            return [.appleTV, .sharing]
#endif

        // MARK: Discontinued

        case .Full.OneTime.iOS_macOS:
            return AppFeature.allCases.filter {
                $0 != .appleTV
            }

        case .Full.OneTime.iOS:
#if os(iOS) || os(tvOS)
            return AppProduct.Full.OneTime.iOS_macOS.features
#else
            return []
#endif

        case .Full.OneTime.macOS:
#if os(macOS) || os(tvOS)
            return AppProduct.Full.OneTime.iOS_macOS.features
#else
            return []
#endif

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
