//
//  ProviderServer.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/15/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import GenericJSON
import CryptoKit
import PassepartoutUtils

public struct ProviderServer: Identifiable {
    public struct Preset {
        public let id: String

        public let name: String

        public let comment: String

        public let vpnProtocol: VPNProtocolType
        
        public let vpnConfiguration: JSON
    }

    public let providerMetadata: ProviderMetadata

    public let id: String
    
    public let apiId: String
    
    public let categoryName: String
    
    public let countryCode: String
    
    public let extraCountryCodes: [String]?
    
    public let serverIndex: Int?
    
    public let details: String?
    
    public let hostname: String?
    
    public let ipAddresses: [String]

    public let presetIds: [String]

    public internal(set) var presets: [Preset]?

    public func preset(withId presetId: String) -> Preset? {
        return presets?.first {
            $0.id == presetId
        }
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
