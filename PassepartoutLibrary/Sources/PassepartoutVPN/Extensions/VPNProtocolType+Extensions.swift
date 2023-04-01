//
//  VPNProtocolType+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/7/22.
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
import TunnelKitOpenVPN
import TunnelKitWireGuard
import PassepartoutCore

extension VPNProtocolType: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.description < rhs.description
    }
}

extension OpenVPN.ProviderConfiguration: VPNProtocolProviding {
    public var vpnProtocol: VPNProtocolType {
        .openVPN
    }
}

extension WireGuard.ProviderConfiguration: VPNProtocolProviding {
    public var vpnProtocol: VPNProtocolType {
        .wireGuard
    }
}

extension VPNProtocolType {
    public var supportsGateway: Bool {
        true
    }

    public var supportsDNS: Bool {
        true
    }

    public var supportsProxy: Bool {
        self == .openVPN
    }

    public var supportsMTU: Bool {
        true
    }
}

extension VPNProtocolProviding {
    func vpnPath(with path: String) -> String {
        var components = path.split(separator: "/").map(String.init)
        components.insert(vpnProtocol.description, at: components.count - 1)
        return components.joined(separator: "/")
    }
}
