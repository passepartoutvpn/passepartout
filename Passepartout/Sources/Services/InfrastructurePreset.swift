//
//  InfrastructurePreset.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/30/18.
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
import TunnelKit

// supports a subset of TunnelKitProvider.Configuration
// ignores new JSON keys

struct InfrastructurePreset: Codable {
    enum PresetKeys: String, CodingKey {
        case id

        case name

        case comment
        
        case configuration = "cfg"
    }

    enum ConfigurationKeys: String, CodingKey {
        case endpointProtocols = "ep"

        case cipher

        case digest = "auth"

        case ca

        case clientCertificate = "client"

        case clientKey = "key"

        case compressionFraming = "frame"
        
        case keepAliveSeconds = "ping"

        case renegotiatesAfterSeconds = "reneg"

        case usesPIAPatches = "pia"
    }
    
    let id: String
    
    let name: String
    
    let comment: String

    let configuration: TunnelKitProvider.Configuration
    
    func hasProtocol(_ proto: EndpointProtocol) -> Bool {
        return configuration.endpointProtocols.index(of: proto) != nil
    }

    // MARK: Codable
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PresetKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        comment = try container.decode(String.self, forKey: .comment)

        let cfgContainer = try container.nestedContainer(keyedBy: ConfigurationKeys.self, forKey: .configuration)
        let ca = try cfgContainer.decode(CryptoContainer.self, forKey: .ca)

        var sessionBuilder = SessionProxy.ConfigurationBuilder(ca: ca)
        sessionBuilder.cipher = try cfgContainer.decode(SessionProxy.Cipher.self, forKey: .cipher)
        if let digest = try cfgContainer.decodeIfPresent(SessionProxy.Digest.self, forKey: .digest) {
            sessionBuilder.digest = digest
        }
        sessionBuilder.clientCertificate = try cfgContainer.decodeIfPresent(CryptoContainer.self, forKey: .clientCertificate)
        sessionBuilder.clientKey = try cfgContainer.decodeIfPresent(CryptoContainer.self, forKey: .clientKey)
        sessionBuilder.compressionFraming = try cfgContainer.decode(SessionProxy.CompressionFraming.self, forKey: .compressionFraming)
        sessionBuilder.keepAliveInterval = try cfgContainer.decodeIfPresent(TimeInterval.self, forKey: .keepAliveSeconds)
        sessionBuilder.renegotiatesAfter = try cfgContainer.decodeIfPresent(TimeInterval.self, forKey: .renegotiatesAfterSeconds)
        sessionBuilder.usesPIAPatches = try cfgContainer.decodeIfPresent(Bool.self, forKey: .usesPIAPatches) ?? false

        var builder = TunnelKitProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        builder.endpointProtocols = try cfgContainer.decode([EndpointProtocol].self, forKey: .endpointProtocols)
        configuration = builder.build()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PresetKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(comment, forKey: .comment)

        var cfgContainer = container.nestedContainer(keyedBy: ConfigurationKeys.self, forKey: .configuration)
        try cfgContainer.encode(configuration.endpointProtocols, forKey: .endpointProtocols)

        try cfgContainer.encode(configuration.sessionConfiguration.cipher, forKey: .cipher)
        try cfgContainer.encode(configuration.sessionConfiguration.digest, forKey: .digest)
        try cfgContainer.encodeIfPresent(configuration.sessionConfiguration.ca, forKey: .ca)
        try cfgContainer.encodeIfPresent(configuration.sessionConfiguration.clientCertificate, forKey: .clientCertificate)
        try cfgContainer.encodeIfPresent(configuration.sessionConfiguration.clientKey, forKey: .clientKey)
        try cfgContainer.encode(configuration.sessionConfiguration.compressionFraming, forKey: .compressionFraming)
        try cfgContainer.encodeIfPresent(configuration.sessionConfiguration.keepAliveInterval, forKey: .keepAliveSeconds)
        try cfgContainer.encodeIfPresent(configuration.sessionConfiguration.renegotiatesAfter, forKey: .renegotiatesAfterSeconds)
        try cfgContainer.encodeIfPresent(configuration.sessionConfiguration.usesPIAPatches, forKey: .usesPIAPatches)
    }
}
