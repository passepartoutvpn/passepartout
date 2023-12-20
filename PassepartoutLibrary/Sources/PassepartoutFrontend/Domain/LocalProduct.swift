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
import PassepartoutCore
import PassepartoutProviders

public struct LocalProduct: RawRepresentable, Hashable, Sendable {
    private static let bundleSubdomain = "ios"

    private static let bundle = "com.algoritmico.\(bundleSubdomain).Passepartout"

    private static let donationsBundle = "\(bundle).donations"

    private static let featuresBundle = "\(bundle).features"

    static let providersBundle = "\(bundle).providers"

    // MARK: Donations

    public static let tinyDonation = LocalProduct(donationDescription: "Tiny")

    public static let smallDonation = LocalProduct(donationDescription: "Small")

    public static let mediumDonation = LocalProduct(donationDescription: "Medium")

    public static let bigDonation = LocalProduct(donationDescription: "Big")

    public static let hugeDonation = LocalProduct(donationDescription: "Huge")

    public static let maxiDonation = LocalProduct(donationDescription: "Maxi")

    public static let allDonations: [LocalProduct] = [
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

    public static let allProviders = LocalProduct(featureId: "all_providers")

    public static let networkSettings = LocalProduct(featureId: "network_settings")

    public static let trustedNetworks = LocalProduct(featureId: "trusted_networks")

    public static let siriShortcuts = LocalProduct(featureId: "siri")

    public static let fullVersion_iOS = LocalProduct(featureId: "full_version")

    public static let fullVersion_macOS = LocalProduct(featureId: "full_mac_version")

    public static let fullVersion = LocalProduct(featureId: "full_multi_version")

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

    public var isDonation: Bool {
        rawValue.hasPrefix(LocalProduct.donationsBundle)
    }

    public var isFeature: Bool {
        rawValue.hasPrefix(LocalProduct.featuresBundle)
    }

    public var isProvider: Bool {
        rawValue.hasPrefix(LocalProduct.providersBundle)
    }

    public var isPlatformVersion: Bool {
        switch self {
        case .fullVersion_iOS, .fullVersion_macOS:
            return true

        default:
            return false
        }
    }

    // MARK: RawRepresentable

    public let rawValue: String

    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension LocalProduct {
    public func matchesInAppProduct(_ iaProduct: InAppProduct) -> Bool {
        iaProduct.productIdentifier == rawValue
    }
}

extension ProviderName {
    public var product: LocalProduct {
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
