//
//  TunnelKit+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/12/22.
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
import NetworkExtension
import PassepartoutLibrary
import TunnelKitManager
import TunnelKitOpenVPN
import TunnelKitWireGuard

extension VPNStatus {
    var localizedDescription: String {
        switch self {
        case .connecting:
            return L10n.Tunnelkit.Vpn.connecting

        case .connected:
            return L10n.Tunnelkit.Vpn.active

        case .disconnecting:
            return L10n.Tunnelkit.Vpn.disconnecting

        case .disconnected:
            return L10n.Tunnelkit.Vpn.inactive
        }
    }
}

extension DataCount {
    var localizedDescription: String {
        let down = received.descriptionAsDataUnit
        let up = sent.descriptionAsDataUnit
        return "↓\(down) ↑\(up)"
    }
}

extension Int {
    var localizedDescriptionAsMTU: String {
        guard self != 0 else {
            return L10n.Global.Strings.default
        }
        return description
    }
}

extension TimeInterval {
    var localizedDescriptionAsKeepAlive: String {
        let V = L10n.Endpoint.Advanced.Openvpn.Items.self
        if self > 0 {
            return V.KeepAlive.Value.seconds(Int(self))
        } else {
            return L10n.Global.Strings.disabled
        }
    }
}

extension IPv4Settings {
    var localizedAddress: String {
        "\(address)/\(addressMask)"
    }

    var localizedDefaultGateway: String {
        defaultGateway
    }
}

extension IPv6Settings {
    var localizedAddress: String {
        "\(address)/\(addressPrefixLength)"
    }

    var localizedDefaultGateway: String {
        defaultGateway
    }
}

extension IPv4Settings.Route {
    var localizedDescription: String {
        "\(destination)/\(mask) -> \(gateway ?? "*")"
    }
}

extension IPv6Settings.Route {
    var localizedDescription: String {
        "\(destination)/\(prefixLength) -> \(gateway ?? "*")"
    }
}
