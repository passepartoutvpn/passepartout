//
//  HostConnectionProfile.m
//  Passepartout
//
//  Created by Davide De Rosa on 9/2/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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

class HostConnectionProfile: ConnectionProfile, Codable, Equatable {
    var title: String

    let hostname: String
    
    var parameters: TunnelKitProvider.Configuration

    init(title: String, hostname: String) {
        self.title = title
        self.hostname = hostname
        let sessionConfiguration = SessionProxy.ConfigurationBuilder(ca: CryptoContainer(pem: "")).build()
        parameters = TunnelKitProvider.ConfigurationBuilder(sessionConfiguration: sessionConfiguration).build()
    }
    
    // MARK: ConnectionProfile
    
    let context: Context = .host
    
    var id: String {
        return title
    }
    
    var username: String?
    
    var requiresCredentials: Bool {
        return false
    }
    
    func generate(from configuration: TunnelKitProvider.Configuration, preferences: Preferences) throws -> TunnelKitProvider.Configuration {
        precondition(!parameters.endpointProtocols.isEmpty)
        
        // XXX: copy paste, error prone
        var builder = parameters.builder()
        builder.mtu = configuration.mtu
        builder.shouldDebug = configuration.shouldDebug
        builder.debugLogFormat = configuration.debugLogFormat

        return builder.build()
    }
}

extension HostConnectionProfile {
    static func ==(lhs: HostConnectionProfile, rhs: HostConnectionProfile) -> Bool {
        return lhs.id == rhs.id
    }
}

extension HostConnectionProfile {
    var mainAddress: String {
        return hostname
    }
    
    var addresses: [String] {
        return [hostname]
    }
    
    var protocols: [TunnelKitProvider.EndpointProtocol] {
        return parameters.endpointProtocols
    }
    
    var canCustomizeEndpoint: Bool {
        return false
    }

    var customAddress: String? {
        return nil
    }
    
    var customProtocol: TunnelKitProvider.EndpointProtocol? {
        return nil
    }
}
