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
        case .beta:
            return [.interactiveLogin, .sharing]

        case .fullVersion:
            return AppFeature.fullV2Features

        case .fullVersionPlusTV:
            return AppFeature.allCases

        default:
            return []
        }
    }
}

extension AppProduct: AppFeatureProviding {
    var features: [AppFeature] {
        switch self {

        // MARK: Current

        case .Features.appleTV:
            return [.appleTV, .sharing]

        case .Full.Recurring.monthly, .Full.Recurring.yearly:
            return AppFeature.allCases

        // MARK: Discontinued

        case .Features.allProviders:
            return [.providers]

        case .Features.networkSettings:
            return [.dns, .httpProxy, .routing]

        case .Features.trustedNetworks:
            return [.onDemand]

        case .Full.allPlatforms:
            return AppFeature.fullV2Features

        case .Full.iOS:
#if os(iOS)
            return AppFeature.fullV2Features
#else
            return []
#endif

        case .Full.macOS:
#if os(macOS)
            return AppFeature.fullV2Features
#else
            return []
#endif

        default:
            return []
        }
    }
}
