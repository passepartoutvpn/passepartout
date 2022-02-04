//
//  HostConnectionProfile.m
//  Passepartout
//
//  Created by Davide De Rosa on 9/2/18.
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
import TunnelKit
import TunnelKitOpenVPN

public class HostConnectionProfile: ConnectionProfile, Codable, Equatable {

    // XXX: drop after @transient serviceDelegate
    public enum CodingKeys: CodingKey {
        case hostname
        
        case parameters
        
        case customAddress
        
        case customProtocol

        case id
        
        case username

        case trustedNetworks

        case networkChoices
        
        case manualNetworkSettings
    }
    
    public let hostname: String
    
    public var parameters: OpenVPNProvider.Configuration

    public var customAddress: String?

    public var customProtocol: EndpointProtocol?
    
    public init(hostname: String) {
        id = UUID().uuidString
        self.hostname = hostname
        let sessionConfiguration = OpenVPN.ConfigurationBuilder().build()
        parameters = OpenVPNProvider.ConfigurationBuilder(sessionConfiguration: sessionConfiguration).build()

        trustedNetworks = TrustedNetworks()
    }
    
    // MARK: ConnectionProfile
    
    public var context: Context {
        return .host
    }
    
    public let id: String
    
    public var username: String?
    
    public var requiresCredentials: Bool {
        return false
    }
    
    public var trustedNetworks: TrustedNetworks!

    public var networkChoices: ProfileNetworkChoices?
    
    public var manualNetworkSettings: ProfileNetworkSettings?
    
    public weak var serviceDelegate: ConnectionServiceDelegate?

    public func generate(from configuration: OpenVPNProvider.Configuration, preferences: Preferences) throws -> OpenVPNProvider.Configuration {
        guard let endpointProtocols = parameters.sessionConfiguration.endpointProtocols, !endpointProtocols.isEmpty else {
            preconditionFailure("No endpointProtocols")
        }
        
        // XXX: copy paste, error prone
        var builder = parameters.builder()
        builder.shouldDebug = configuration.shouldDebug
        builder.debugLogFormat = configuration.debugLogFormat
        builder.masksPrivateData = configuration.masksPrivateData

        if let address = customAddress {
            builder.prefersResolvedAddresses = true
            builder.resolvedAddresses = [address]
        }
        
        // forcibly override hostname with profile hostname (never nil)
        var sessionBuilder = builder.sessionConfiguration.builder()
        sessionBuilder.hostname = hostname
        sessionBuilder.tlsSecurityLevel = 0 // lowest, tolerate widest range of certificates
        if sessionBuilder.mtu == nil {
            sessionBuilder.mtu = configuration.sessionConfiguration.mtu
        }

        if let proto = customProtocol {
            sessionBuilder.endpointProtocols = [proto]
        } else {
            
            // restrict "Any" protocol to UDP, unless there are no UDP endpoints
            let allEndpoints = builder.sessionConfiguration.endpointProtocols
            var endpoints = allEndpoints?.filter { $0.socketType == .udp }
            if endpoints?.isEmpty ?? true {
                endpoints = allEndpoints
            }
            sessionBuilder.endpointProtocols = endpoints
        }

        builder.sessionConfiguration = sessionBuilder.build()

        return builder.build()
    }
}

public extension HostConnectionProfile {
    static func ==(lhs: HostConnectionProfile, rhs: HostConnectionProfile) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension HostConnectionProfile {
    var mainAddress: String? {
        return hostname
    }
    
    var addresses: [String] {
        return [hostname]
    }
    
    var protocols: [EndpointProtocol] {
        return parameters.sessionConfiguration.endpointProtocols ?? []
    }
    
    var canCustomizeEndpoint: Bool {
        return true
    }
}
