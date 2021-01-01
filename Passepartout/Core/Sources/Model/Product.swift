//
//  Product.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/11/19.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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

public struct Product: RawRepresentable, Equatable, Hashable {
    #if os(iOS)
    private static let bundleSubdomain = "ios"
    #else
    private static let bundleSubdomain = "macos"
    #endif

    private static let bundle = "com.algoritmico.\(bundleSubdomain).Passepartout"

    private static let donationsBundle = "\(bundle).donations"
    
    private static let featuresBundle = "\(bundle).features"
    
    private static let providersBundle = "\(bundle).providers"
    
    // MARK: Donations
    
    public static let tinyDonation = Product(donationDescription: "Tiny")

    public static let smallDonation = Product(donationDescription: "Small")

    public static let mediumDonation = Product(donationDescription: "Medium")

    public static let bigDonation = Product(donationDescription: "Big")

    public static let hugeDonation = Product(donationDescription: "Huge")

    public static let maxiDonation = Product(donationDescription: "Maxi")
    
    public static let allDonations: [Product] = [
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

    #if os(iOS)
    public static let unlimitedHosts = Product(featureId: "unlimited_hosts")

    public static let trustedNetworks = Product(featureId: "trusted_networks")

    public static let siriShortcuts = Product(featureId: "siri")
    #endif

    public static let fullVersion = Product(featureId: "full_version")
    
    #if os(iOS)
    public static let allFeatures: [Product] = [
        .unlimitedHosts,
        .trustedNetworks,
        .siriShortcuts,
        .fullVersion
    ]
    #else
    public static let allFeatures: [Product] = [
        .fullVersion
    ]
    #endif

    private init(featureId: String) {
        self.init(rawValue: "\(Product.featuresBundle).\(featureId)")!
    }

    // MARK: Providers

    public static var allProviders: [Product] {
        return InfrastructureFactory.shared.allMetadata.map {
            return Product(providerMetadata: $0)
        }
    }
    
    fileprivate init(providerMetadata: Infrastructure.Metadata) {
        self.init(rawValue: "\(Product.providersBundle).\(providerMetadata.inApp ?? providerMetadata.name)")!
    }

    // MARK: All

    public static var all: [Product] {
        return allDonations + allFeatures + allProviders
    }
    
    public var isDonation: Bool {
        return rawValue.hasPrefix(Product.donationsBundle)
    }

    public var isFeature: Bool {
        return rawValue.hasPrefix(Product.featuresBundle)
    }

    public var isProvider: Bool {
        return rawValue.hasPrefix(Product.providersBundle)
    }
    
    // MARK: RawRepresentable
    
    public let rawValue: String
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }

    // MARK: Equatable
    
    public static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        rawValue.hash(into: &hasher)
    }
}

public extension Infrastructure.Metadata {
    var product: Product {
        return Product(providerMetadata: self)
    }
}

public extension Product {
    func matchesStoreKitProduct(_ skProduct: SKProduct) -> Bool {
        return skProduct.productIdentifier == rawValue
    }
}
