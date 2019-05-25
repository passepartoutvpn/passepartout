//
//  HostConnectionProfile.m
//  Passepartout
//
//  Created by Davide De Rosa on 9/2/18.
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

public class HostConnectionProfile: ConnectionProfile, Codable, Equatable {
    public var title: String

    public let hostname: String
    
    public var parameters: OpenVPNTunnelProvider.Configuration

    public init(title: String, hostname: String) {
        self.title = title
        self.hostname = hostname
        let sessionConfiguration = OpenVPN.ConfigurationBuilder().build()
        parameters = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: sessionConfiguration).build()
    }
    
    // MARK: ConnectionProfile
    
    public let context: Context = .host
    
    public var id: String {
        return title
    }
    
    public var username: String?
    
    public var requiresCredentials: Bool {
        return false
    }
    
    public var networkChoices: ProfileNetworkChoices?
    
    public var manualNetworkSettings: ProfileNetworkSettings?
    
    public func generate(from configuration: OpenVPNTunnelProvider.Configuration, preferences: Preferences) throws -> OpenVPNTunnelProvider.Configuration {
        guard let endpointProtocols = parameters.sessionConfiguration.endpointProtocols, !endpointProtocols.isEmpty else {
            preconditionFailure("No endpointProtocols")
        }
        
        // XXX: copy paste, error prone
        var builder = parameters.builder()
        builder.mtu = configuration.mtu
        builder.shouldDebug = configuration.shouldDebug
        builder.debugLogFormat = configuration.debugLogFormat
        builder.masksPrivateData = configuration.masksPrivateData

        // forcibly override hostname with profile hostname (never nil)
        var sessionBuilder = builder.sessionConfiguration.builder()
        sessionBuilder.hostname = hostname
        sessionBuilder.tlsSecurityLevel = 0 // lowest, tolerate widest range of certificates
        builder.sessionConfiguration = sessionBuilder.build()

        return builder.build()
    }
    
    public func with(newId: String) -> ConnectionProfile {
        let profile = HostConnectionProfile(title: newId, hostname: hostname)
        profile.username = username
        profile.parameters = parameters
        return profile
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
        return false
    }

    var customAddress: String? {
        return nil
    }
    
    var customProtocol: EndpointProtocol? {
        return nil
    }
}
