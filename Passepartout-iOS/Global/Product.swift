//
//  Product.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 10/11/19.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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

enum Product: String {
    
    // MARK: Donations
    
    case tinyDonation = "com.algoritmico.ios.Passepartout.donations.Tiny"

    case smallDonation = "com.algoritmico.ios.Passepartout.donations.Small"

    case mediumDonation = "com.algoritmico.ios.Passepartout.donations.Medium"

    case bigDonation = "com.algoritmico.ios.Passepartout.donations.Big"

    case hugeDonation = "com.algoritmico.ios.Passepartout.donations.Huge"

    case maxiDonation = "com.algoritmico.ios.Passepartout.donations.Maxi"
    
    static let allDonations: [Product] = [
        .tinyDonation,
        .smallDonation,
        .mediumDonation,
        .bigDonation,
        .hugeDonation,
        .maxiDonation
    ]

    // MARK: Features

    case unlimitedHosts = "com.algoritmico.ios.Passepartout.features.unlimited_hosts"

    case trustedNetworks = "com.algoritmico.ios.Passepartout.features.trusted_networks"

    case siriShortcuts = "com.algoritmico.ios.Passepartout.features.siri"

    case fullVersion = "com.algoritmico.ios.Passepartout.features.full_version"
    
    static let allFeatures: [Product] = [
        .unlimitedHosts,
        .trustedNetworks,
        .siriShortcuts,
        .fullVersion
    ]

    // MARK: Providers

    case mullvad = "com.algoritmico.ios.Passepartout.providers.Mullvad"

    case nordVPN = "com.algoritmico.ios.Passepartout.providers.NordVPN"

    case pia = "com.algoritmico.ios.Passepartout.providers.PIA"

    case protonVPN = "com.algoritmico.ios.Passepartout.providers.ProtonVPN"

    case tunnelBear = "com.algoritmico.ios.Passepartout.providers.TunnelBear"

    case vyprVPN = "com.algoritmico.ios.Passepartout.providers.VyprVPN"

    case windscribe = "com.algoritmico.ios.Passepartout.providers.Windscribe"

    static let allProviders: [Product] = [
        .mullvad,
        .nordVPN,
        .pia,
        .protonVPN,
        .tunnelBear,
        .vyprVPN,
        .windscribe
    ]
    
    // MARK: All

    static let all: [Product] = allDonations + allFeatures + allProviders
}

extension Infrastructure.Name {
    var product: Product {
        guard let product = Product(rawValue: "com.algoritmico.ios.Passepartout.providers.\(rawValue)") else {
            fatalError("Product not found for provider \(rawValue)")
        }
        return product
    }
}
