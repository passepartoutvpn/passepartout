//
//  PassepartoutKit+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/24.
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
import PassepartoutKit
import UtilsLibrary

extension TunnelStatus: LocalizableEntity {
    public var localizedDescription: String {
        let V = Strings.Entities.TunnelStatus.self
        switch self {
        case .inactive:
            return V.inactive

        case .activating:
            return V.activating

        case .active:
            return V.active

        case .deactivating:
            return V.deactivating
        }
    }
}

extension ConnectionStatus: LocalizableEntity {
    public var localizedDescription: String {
        let V = Strings.Entities.ConnectionStatus.self
        switch self {
        case .disconnected:
            return V.disconnected

        case .connecting:
            return V.connecting

        case .connected:
            return V.connected

        case .disconnecting:
            return V.disconnecting
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

extension Address.Family: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .v4:
            return Strings.Unlocalized.ipv4

        case .v6:
            return Strings.Unlocalized.ipv6
        }
    }
}

extension IPSettings: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case address

        case defaultGateway
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .address:
            return addressDescription

        case .defaultGateway:
            return defaultGatewayDescription
        }
    }

    private var addressDescription: String? {
        subnet?.address.rawValue
    }

    private var defaultGatewayDescription: String? {
        includedRoutes
            .first(where: \.isDefault)?
            .gateway?
            .rawValue
    }
}

extension Route: LocalizableEntity {
    public var localizedDescription: String {
        if let dest = destination?.rawValue {
            if let gw = gateway?.rawValue {
                return "\(dest) → \(gw)"
            } else {
                return dest
            }
        } else if let gw = gateway?.rawValue {
            return "default → \(gw)"
        }
        return "default → *"
    }
}

extension OnDemandModule.Policy: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .any:
            return Strings.Entities.OnDemand.Policy.any

        case .excluding:
            return Strings.Entities.OnDemand.Policy.excluding

        case .including:
            return Strings.Entities.OnDemand.Policy.including
        }
    }
}

extension OpenVPN.Credentials.OTPMethod: StyledLocalizableEntity {
    public enum Style {
        case entity

        case approachDescription
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .entity:
            let V = Strings.Entities.Openvpn.OtpMethod.self
            switch self {
            case .none:
                return V.none

            case .append:
                return V.append

            case .encode:
                return V.encode
            }

        case .approachDescription:
            let V = Strings.Modules.Openvpn.Credentials.OtpMethod.Approach.self
            switch self {
            case .none:
                return ""

            case .append:
                return V.append

            case .encode:
                return V.encode
            }
        }
    }
}
