//
//  ConnectionProfile.swift
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
import NetworkExtension

public enum Context: String, Codable {
    case provider
    
    case host
}

public protocol ConnectionProfile: class, EndpointDataSource, CustomStringConvertible {
    var context: Context { get }
    
    var id: String { get }
    
    var username: String? { get set }
    
    var requiresCredentials: Bool { get }
    
    var networkChoices: ProfileNetworkChoices? { get set }
    
    var manualNetworkSettings: ProfileNetworkSettings? { get set }
    
    func generate(from configuration: OpenVPNTunnelProvider.Configuration, preferences: Preferences) throws -> OpenVPNTunnelProvider.Configuration

    func with(newId: String) -> ConnectionProfile
}

public extension ConnectionProfile {
    var passwordKey: String? {
        guard let username = username else {
            return nil
        }
        return "\(Bundle.main.bundleIdentifier!).\(context.rawValue).\(id).\(username)"
    }

    func password(in keychain: Keychain) -> String? {
        guard let key = passwordKey else {
            return nil
        }
        return try? keychain.password(for: key)
    }
    
    func setPassword(_ password: String?, in keychain: Keychain) throws {
        guard let key = passwordKey else {
            return
        }
        guard let password = password else {
            keychain.removePassword(for: key)
            return
        }
        try keychain.set(password: password, for: key, label: key)
    }
    
    func removePassword(in keychain: Keychain) {
        guard let key = passwordKey else {
            return
        }
        keychain.removePassword(for: key)
    }
}

public extension ConnectionProfile {
    var description: String {
        return "(\(context):\(id))"
    }
}
