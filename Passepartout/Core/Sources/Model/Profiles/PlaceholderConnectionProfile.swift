//
//  PlaceholderConnectionProfile.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/6/18.
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
import TunnelKit

public class PlaceholderConnectionProfile: ConnectionProfile {
    public let context: Context
    
    public let id: String
    
    public var username: String? = nil
    
    public var requiresCredentials: Bool = false
    
    public var trustedNetworks: TrustedNetworks! {
        get {
            fatalError("Getting trustedNetworks of a PlaceholderConnectionProfile")
        }
        set {
            fatalError("Setting trustedNetworks of a PlaceholderConnectionProfile")
        }
    }

    public var networkChoices: ProfileNetworkChoices?
    
    public var manualNetworkSettings: ProfileNetworkSettings?
    
    public func generate(from configuration: OpenVPNTunnelProvider.Configuration, preferences: Preferences) throws -> OpenVPNTunnelProvider.Configuration {
        fatalError("Generating configuration from a PlaceholderConnectionProfile")
    }
    
    public var mainAddress: String? = nil
    
    public var addresses: [String] = []
    
    public var protocols: [EndpointProtocol] = []
    
    public var canCustomizeEndpoint: Bool = false
    
    public var customAddress: String?
    
    public var customProtocol: EndpointProtocol?
    
    public init(_ context: Context, _ id: String) {
        self.context = context
        self.id = id
    }

    public init(_ key: ProfileKey) {
        context = key.context
        id = key.id
    }
}
