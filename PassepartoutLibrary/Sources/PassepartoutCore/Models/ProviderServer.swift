//
//  ProviderServer.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/15/22.
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
import GenericJSON

public struct ProviderServer: Identifiable {
    public struct Preset {
        public let id: String

        public let name: String

        public let comment: String

        public let vpnProtocol: VPNProtocolType

        public let vpnConfiguration: JSON

        public init(id: String, name: String, comment: String, vpnProtocol: VPNProtocolType, vpnConfiguration: JSON) {
            self.id = id
            self.name = name
            self.comment = comment
            self.vpnProtocol = vpnProtocol
            self.vpnConfiguration = vpnConfiguration
        }
    }

    public let providerMetadata: ProviderMetadata

    public let id: String

    public let apiId: String

    public let categoryName: String

    public let countryCode: String

    public let extraCountryCodes: [String]?

    public let localizedName: String?

    public let serverIndex: Int?

    public let tags: [String]?

    public let hostname: String?

    public let ipAddresses: [String]

    public let presetIds: [String]

    public private(set) var presets: [Preset]?

    public init(providerMetadata: ProviderMetadata, id: String, apiId: String, categoryName: String, countryCode: String, extraCountryCodes: [String]?, localizedName: String?, serverIndex: Int?, tags: [String]?, hostname: String?, ipAddresses: [String], presetIds: [String]) {
        self.providerMetadata = providerMetadata
        self.id = id
        self.apiId = apiId
        self.categoryName = categoryName
        self.countryCode = countryCode
        self.extraCountryCodes = extraCountryCodes
        self.localizedName = localizedName
        self.serverIndex = serverIndex
        self.tags = tags
        self.hostname = hostname
        self.ipAddresses = ipAddresses
        self.presetIds = presetIds
    }

    public func preset(withId presetId: String) -> Preset? {
        presets?.first {
            $0.id == presetId
        }
    }

    public func withPresets(_ presets: [Preset]?) -> Self {
        var copy = self
        copy.presets = presets
        return copy
    }
}
