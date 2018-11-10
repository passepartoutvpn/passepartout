//
//  PlaceholderConnectionProfile.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/6/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
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

class PlaceholderConnectionProfile: ConnectionProfile {
    let context: Context
    
    let id: String
    
    var username: String? = nil
    
    var requiresCredentials: Bool = false
    
    func generate(from configuration: TunnelKitProvider.Configuration, preferences: Preferences) throws -> TunnelKitProvider.Configuration {
        fatalError("Generating configuration from a PlaceholderConnectionProfile")
    }
    
    func with(newId: String) -> ConnectionProfile {
        return PlaceholderConnectionProfile(context, newId)
    }
    
    var mainAddress: String = ""
    
    var addresses: [String] = []
    
    var protocols: [TunnelKitProvider.EndpointProtocol] = []
    
    var canCustomizeEndpoint: Bool = false
    
    var customAddress: String?
    
    var customProtocol: TunnelKitProvider.EndpointProtocol?
    
    init(_ context: Context, _ id: String) {
        self.context = context
        self.id = id
    }

    init(_ key: ProfileKey) {
        context = key.context
        id = key.id
    }
}
