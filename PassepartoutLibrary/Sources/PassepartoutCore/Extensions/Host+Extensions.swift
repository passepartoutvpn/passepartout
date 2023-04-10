//
//  Host+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
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
import TunnelKitCore

extension Profile {
    public var hostAccount: Profile.Account? {
        get {
            switch currentVPNProtocol {
            case .openVPN:
                return host?.ovpnSettings?.account

            case .wireGuard:
                return nil
            }
        }
        set {
            switch currentVPNProtocol {
            case .openVPN:
                host?.ovpnSettings?.account = newValue

            case .wireGuard:
                break
            }
        }
    }

    public var hostOpenVPNSettings: OpenVPNSettings? {
        get {
            return host?.ovpnSettings
        }
        set {
            host?.ovpnSettings = newValue
        }
    }

    public var hostWireGuardSettings: WireGuardSettings? {
        get {
            host?.wgSettings
        }
        set {
            host?.wgSettings = newValue
        }
    }

    public var hostCustomEndpoint: Endpoint? {
        switch currentVPNProtocol {
        case .openVPN:
            return host?.ovpnSettings?.customEndpoint

        case .wireGuard:
            return nil
        }
    }
}

extension Profile.Host: ProfileSubtype {
    public var vpnProtocols: [VPNProtocolType] {
        if ovpnSettings != nil {
            return [.openVPN]
        } else if wgSettings != nil {
            return [.wireGuard]
        } else {
            assertionFailure("No VPN settings found")
            return []
        }
    }
}
