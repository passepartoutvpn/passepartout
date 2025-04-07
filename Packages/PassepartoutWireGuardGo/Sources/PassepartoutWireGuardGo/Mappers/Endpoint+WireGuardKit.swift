//
//  Endpoint+WireGuardKit.swift
//  Partout
//
//  Created by Davide De Rosa on 3/25/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Partout
internal import WireGuardKit

extension Partout.Endpoint {
    init?(wg: WireGuardKit.Endpoint) {
        guard let address = Address(rawValue: wg.host.debugDescription) else {
            return nil
        }
        self.init(address, wg.port.rawValue)
    }

    func toWireGuardEndpoint() throws -> WireGuardKit.Endpoint {
        let wgAddress: String
        switch address {
        case .ip(let raw, let family):
            wgAddress = family == .v6 ? "[\(raw)]" : raw
        case .hostname(let raw):
            wgAddress = raw
        }
        guard let wg = WireGuardKit.Endpoint(from: "\(wgAddress):\(port)") else {
            throw PartoutError(.parsing)
        }
        return wg
    }
}

extension WireGuardKit.Endpoint {
    var toEndpoint: Partout.Endpoint? {
        .init(wg: self)
    }
}
