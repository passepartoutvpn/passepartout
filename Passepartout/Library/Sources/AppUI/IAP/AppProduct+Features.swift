//
//  AppProduct+Features.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/10/24.
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

extension AppProduct {
    public enum Features {
        public static let allProviders = AppProduct(featureId: "all_providers")

        public static let appleTV = AppProduct(featureId: "appletv")

        public static let networkSettings = AppProduct(featureId: "network_settings")

        public static let siriShortcuts = AppProduct(featureId: "siri")

        public static let trustedNetworks = AppProduct(featureId: "trusted_networks")

        static let all: [AppProduct] = [
            .Features.allProviders,
            .Features.appleTV,
            .Features.networkSettings,
            .Features.siriShortcuts,
            .Features.trustedNetworks
        ]
    }

    public enum Full {
        public static let iOS = AppProduct(featureId: "full_version")

        public static let macOS = AppProduct(featureId: "full_mac_version")

        public static let allPlatforms = AppProduct(featureId: "full_multi_version")

        static let all: [AppProduct] = [
            .Full.iOS,
            .Full.macOS,
            .Full.allPlatforms
        ]
    }

    static let featurePrefix = "features."

    private init(featureId: String) {
        self.init(rawValue: "\(Self.featurePrefix)\(featureId)")!
    }

    var isFeature: Bool {
        rawValue.hasPrefix(Self.featurePrefix)
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
