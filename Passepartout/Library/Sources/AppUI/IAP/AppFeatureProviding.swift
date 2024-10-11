//
//  AppFeatureProviding.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/11/24.
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

protocol AppFeatureProviding {
    var features: [AppFeature] { get }
}

extension AppUserLevel: AppFeatureProviding {
    var features: [AppFeature] {
        switch self {
        case .fullVersion:
            return AppFeature.fullVersionFeaturesV2

        case .fullVersionPlusTV:
            var list = AppFeature.fullVersionFeaturesV2
            list.append(.appleTV)
            return list

        default:
            return []
        }
    }
}

extension AppProduct: AppFeatureProviding {
    var features: [AppFeature] {
        switch self {
        case .Features.allProviders:
            return [.providers]

        case .Features.appleTV:
            return [.appleTV]

        case .Features.networkSettings:
            return [.dns, .httpProxy, .routing]

        case .Features.siriShortcuts:
            return [.siri]

        case .Features.trustedNetworks:
            return [.onDemand]

        case .Full.allPlatforms:
            return AppFeature.fullVersionFeaturesV2

        case .Full.iOS:
#if os(iOS)
            return AppFeature.fullVersionFeaturesV2
#else
            return []
#endif

        case .Full.macOS:
#if os(macOS)
            return AppFeature.fullVersionFeaturesV2
#else
            return []
#endif

        default:
            return []
        }
    }
}
