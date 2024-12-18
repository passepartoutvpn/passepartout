//
//  AppFeatureProviding+Products.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/20/24.
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

import Foundation

extension AppProduct: AppFeatureProviding {
    public var features: [AppFeature] {
        switch self {

        // MARK: Current

        case .Full.OneTime.iOS_macOS:
            return AppFeature.fullFeatures

        case .Full.OneTime.allFeatures, .Full.Recurring.monthly, .Full.Recurring.yearly:
            return AppFeature.fullTVFeatures

        case .Features.appleTV:
            return [.appleTV, .sharing]

        // MARK: Discontinued

        case .Full.OneTime.iOS:
#if os(iOS)
            return AppFeature.fullFeatures
#else
            return []
#endif

        case .Full.OneTime.macOS:
#if os(macOS)
            return AppFeature.fullFeatures
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
