//
//  TunnelKit+Extensions.swift
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
import TunnelKitCore

extension Endpoint: Identifiable {
    public var id: String {
        [address, proto.port.description, proto.socketType.rawValue].joined(separator: ":")
    }
}

extension Endpoint: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs.address != rhs.address else {
            return lhs.proto < rhs.proto
        }
        guard lhs.isHostname == rhs.isHostname else {
            return lhs.isHostname
        }
        return lhs.address < rhs.address
    }
}

extension Endpoint: Hashable {
}

extension EndpointProtocol: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs.socketType != rhs.socketType else {
            return lhs.port < rhs.port
        }
        return lhs.socketType.orderValue < rhs.socketType.orderValue
    }
}

private extension SocketType {
    var orderValue: Int {
        switch self {
        case .udp: return 1
        case .udp4: return 2
        case .udp6: return 3
        case .tcp: return 4
        case .tcp4: return 5
        case .tcp6: return 6
        }
    }
}

extension IPv4Settings.Route: Identifiable {
    public var id: String {
        [destination, mask, gateway ?? "*"].joined(separator: ":")
    }
}

extension IPv6Settings.Route: Identifiable {
    public var id: String {
        [destination, prefixLength.description, gateway ?? "*"].joined(separator: ":")
    }
}
