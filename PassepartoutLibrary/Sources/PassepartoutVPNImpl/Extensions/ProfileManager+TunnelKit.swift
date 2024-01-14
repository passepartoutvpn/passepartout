//
//  ProfileManager+TunnelKit.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/7/22.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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
import PassepartoutVPN
import TunnelKitOpenVPN
import TunnelKitWireGuard

extension ProfileManager {
    public func profile(withHeader header: Profile.Header, fromURL url: URL, passphrase: String?) throws -> Profile {
        let contents = try String(contentsOf: url)
        return try profile(withHeader: header, fromContents: contents, originalURL: url, passphrase: passphrase)
    }

    public func profile(withHeader header: Profile.Header, fromContents contents: String, originalURL: URL?, passphrase: String?) throws -> Profile {
        do {
            let ovpn = try OpenVPN.ConfigurationParser.parsed(fromContents: contents, passphrase: passphrase, originalURL: originalURL)
            return Profile(header, configuration: ovpn.configuration)
        } catch let ovpnError as OpenVPN.ConfigurationError {
            do {
                let wg = try WireGuard.Configuration(wgQuickConfig: contents)
                return Profile(header, configuration: wg)
            } catch WireGuard.ConfigurationError.invalidLine {
                switch ovpnError {
                case .encryptionPassphrase, .unableToDecrypt:
                    throw Passepartout.ProfileError.decryptionFailure(error: ovpnError)

                default:
                    throw Passepartout.ProfileError.importFailure(error: ovpnError)
                }
            } catch let wgError {
                throw Passepartout.ProfileError.importFailure(error: wgError)
            }
        }
    }
}
