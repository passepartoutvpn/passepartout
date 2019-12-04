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

struct Product: RawRepresentable, Equatable, Hashable {
    private static let bundle = "com.algoritmico.ios.Passepartout"
    
    private static let donationsBundle = "\(bundle).donations"
    
    private static let featuresBundle = "\(bundle).features"
    
    private static let providersBundle = "\(bundle).providers"
    
    // MARK: Donations
    
    static let tinyDonation = Product(donationDescription: "Tiny")

    static let smallDonation = Product(donationDescription: "Small")

    static let mediumDonation = Product(donationDescription: "Medium")

    static let bigDonation = Product(donationDescription: "Big")

    static let hugeDonation = Product(donationDescription: "Huge")

    static let maxiDonation = Product(donationDescription: "Maxi")
    
    static let allDonations: [Product] = [
        .tinyDonation,
        .smallDonation,
        .mediumDonation,
        .bigDonation,
        .hugeDonation,
        .maxiDonation
    ]

    private init(donationDescription: String) {
        self.init(rawValue: "\(Product.donationsBundle).\(donationDescription)")!
    }

    // MARK: Features

    static let unlimitedHosts = Product(featureId: "unlimited_hosts")

    static let trustedNetworks = Product(featureId: "trusted_networks")

    static let siriShortcuts = Product(featureId: "features.siri")

    static let fullVersion = Product(featureId: "full_version")
    
    static let allFeatures: [Product] = [
        .unlimitedHosts,
        .trustedNetworks,
        .siriShortcuts,
        .fullVersion
    ]
    
    private init(featureId: String) {
        self.init(rawValue: "\(Product.featuresBundle).\(featureId)")!
    }

    // MARK: Providers

    static var allProviders: [Product] {
        return InfrastructureFactory.shared.allMetadata.map {
            return Product(providerId: $0.description)
        }
    }
    
    fileprivate init(providerId: String) {
        self.init(rawValue: "\(Product.providersBundle).\(providerId)")!
    }

    // MARK: All

    static var all: [Product] {
        return allDonations + allFeatures + allProviders
    }
    
    var isDonation: Bool {
        return rawValue.hasPrefix(Product.donationsBundle)
    }

    var isFeature: Bool {
        return rawValue.hasPrefix(Product.featuresBundle)
    }

    var isProvider: Bool {
        return rawValue.hasPrefix(Product.providersBundle)
    }
    
    // MARK: RawRepresentable
    
    let rawValue: String
    
    init?(rawValue: String) {
        self.rawValue = rawValue
    }

    // MARK: Equatable
    
    static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    // MARK: Hashable
    
    func hash(into hasher: inout Hasher) {
        rawValue.hash(into: &hasher)
    }
}

extension Infrastructure.Metadata {
    var product: Product {
        return Product(providerId: inApp ?? description)
    }
}
