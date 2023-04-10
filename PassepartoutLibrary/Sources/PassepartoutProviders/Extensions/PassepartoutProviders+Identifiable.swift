//
//  PassepartoutProviders+Identifiable.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/25/22.
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
import CryptoKit

// primary keys within infrastructure (pinned: vpnProtocol)

extension ProviderCategory: Identifiable {
    public var id: String {
        "\(providerMetadata.name):\(name)"
    }
}

extension ProviderLocation: Identifiable {
    public var id: String {
        "\(providerMetadata.name):\(categoryName):\(countryCode)"
    }
}

extension ProviderServer {
    public var locationId: String {
        "\(providerMetadata.name):\(categoryName):\(countryCode)"
    }

    public func location(withVPNProtocol vpnProtocol: VPNProtocolType) -> ProviderLocation {
        ProviderLocation(
            providerMetadata: providerMetadata,
            vpnProtocol: vpnProtocol,
            categoryName: categoryName,
            countryCode: countryCode,
            servers: nil
        )
    }
}

extension ProviderServer {
    public static func id(withName providerName: ProviderName, vpnProtocol: VPNProtocolType, apiId: String) -> String? {
        let idSource = "\(providerName):\(vpnProtocol.rawValue):\(apiId)"
        guard let data = idSource.data(using: .utf8) else {
            return nil
        }
        let sha = SHA256.hash(data: data)
        return sha.map {
            String(format: "%02X", $0)
        }.joined()
    }
}
