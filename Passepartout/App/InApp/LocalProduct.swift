//
//  LocalProduct.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/11/19.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import StoreKit
import PassepartoutLibrary

struct LocalProduct: RawRepresentable, Equatable, Hashable {
    private static let bundleSubdomain = "ios"

    private static let bundle = "com.algoritmico.\(bundleSubdomain).Passepartout"

    private static let donationsBundle = "\(bundle).donations"

    private static let featuresBundle = "\(bundle).features"

    static let providersBundle = "\(bundle).providers"

    // MARK: Donations

    static let tinyDonation = LocalProduct(donationDescription: "Tiny")

    static let smallDonation = LocalProduct(donationDescription: "Small")

    static let mediumDonation = LocalProduct(donationDescription: "Medium")

    static let bigDonation = LocalProduct(donationDescription: "Big")

    static let hugeDonation = LocalProduct(donationDescription: "Huge")

    static let maxiDonation = LocalProduct(donationDescription: "Maxi")

    static let allDonations: [LocalProduct] = [
        .tinyDonation,
        .smallDonation,
        .mediumDonation,
        .bigDonation,
        .hugeDonation,
        .maxiDonation
    ]

    private init(donationDescription: String) {
        self.init(rawValue: "\(LocalProduct.donationsBundle).\(donationDescription)")!
    }

    // MARK: Features

    static let allProviders = LocalProduct(featureId: "all_providers")

    static let networkSettings = LocalProduct(featureId: "network_settings")

    static let trustedNetworks = LocalProduct(featureId: "trusted_networks")

    static let siriShortcuts = LocalProduct(featureId: "siri")

    static let fullVersion_iOS = LocalProduct(featureId: "full_version")

    static let fullVersion_macOS = LocalProduct(featureId: "full_mac_version")

    static let fullVersion = LocalProduct(featureId: "full_multi_version")

    static let allFeatures: [LocalProduct] = [
        .allProviders,
        .networkSettings,
        .trustedNetworks,
        .siriShortcuts,
        .fullVersion_iOS,
        .fullVersion_macOS,
        .fullVersion
    ]

    private init(featureId: String) {
        self.init(rawValue: "\(LocalProduct.featuresBundle).\(featureId)")!
    }

    // MARK: All

    static var all: [LocalProduct] {
        allDonations + allFeatures// + allProviders
    }

    var isDonation: Bool {
        rawValue.hasPrefix(LocalProduct.donationsBundle)
    }

    var isFeature: Bool {
        rawValue.hasPrefix(LocalProduct.featuresBundle)
    }

    var isProvider: Bool {
        rawValue.hasPrefix(LocalProduct.providersBundle)
    }

    // MARK: RawRepresentable

    let rawValue: String

    init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension LocalProduct {
    func matchesStoreKitProduct(_ skProduct: SKProduct) -> Bool {
        skProduct.productIdentifier == rawValue
    }
}

extension ProviderName {
    var product: LocalProduct {
        .init(rawValue: "\(LocalProduct.providersBundle).\(inApp)")!
    }
}

// legacy in-app products
private extension ProviderName {
    var inApp: String {
        switch self {
        case .mullvad:
            return "Mullvad"

        case .nordvpn:
            return "NordVPN"

        case .pia:
            return "PIA"

        case .protonvpn:
            return "ProtonVPN"

        case .tunnelbear:
            return "TunnelBear"

        case .vyprvpn:
            return "VyprVPN"

        case .windscribe:
            return "Windscribe"

        default:
            return self
        }
    }
}
