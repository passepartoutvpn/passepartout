//
//  TunnelKit+L10n.swift
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
import NetworkExtension
import PassepartoutLibrary
import TunnelKitManager
import TunnelKitOpenVPN
import TunnelKitWireGuard

extension VPNStatus: LocalizableEntity {
    public var localizedDescription: String {
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

extension DataCount: LocalizableEntity {
    public var localizedDescription: String {
        let down = received.descriptionAsDataUnit
        let up = sent.descriptionAsDataUnit
        return "↓\(down) ↑\(up)"
    }
}

extension IPv4Settings: StyledLocalizableEntity {
    public enum Style {
        case address

        case defaultGateway
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .address:
            return addressDescription

        case .defaultGateway:
            return defaultGatewayDescription
        }
    }

    private var addressDescription: String {
        "\(address)/\(addressMask)"
    }

    private var defaultGatewayDescription: String {
        defaultGateway
    }
}

extension IPv6Settings: StyledLocalizableEntity {
    public enum Style {
        case address

        case defaultGateway
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .address:
            return addressDescription

        case .defaultGateway:
            return defaultGatewayDescription
        }
    }

    private var addressDescription: String {
        "\(address)/\(addressPrefixLength)"
    }

    private var defaultGatewayDescription: String {
        defaultGateway
    }
}

extension IPv4Settings.Route: LocalizableEntity {
    public var localizedDescription: String {
        "\(destination)/\(mask) → \(gateway ?? "*")"
    }
}

extension IPv6Settings.Route: LocalizableEntity {
    public var localizedDescription: String {
        "\(destination)/\(prefixLength) → \(gateway ?? "*")"
    }
}
