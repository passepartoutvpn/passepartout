//
//  WireGuard+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/12/22.
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
import PassepartoutLibrary
import TunnelKitWireGuard

extension WireGuard.ConfigurationBuilder: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case keepAlive(peerIndex: Int)
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .keepAlive(let peerIndex):
            return keepAlive(ofPeer: peerIndex)?.keepAliveDescription
        }
    }
}

private extension UInt16 {
    var keepAliveDescription: String {
        // TODO: l10n, move from OpenVPN to shared
        let V = L10n.Endpoint.Advanced.Openvpn.Items.self
        if self > 0 {
            return V.KeepAlive.Value.seconds(Int(self))
        } else {
            return L10n.Global.Strings.disabled
        }
    }
}

// MARK: - Errors

extension TunnelKitWireGuardError: LocalizedError {
    public var errorDescription: String? {
        let V = L10n.Tunnelkit.Errors.Vpn.self
        switch self {
        case .dnsResolutionFailure:
            return V.dns

        default:
            return L10n.Global.Strings.unknown
        }
    }
}

extension WireGuard.ConfigurationError: LocalizedError {
}
