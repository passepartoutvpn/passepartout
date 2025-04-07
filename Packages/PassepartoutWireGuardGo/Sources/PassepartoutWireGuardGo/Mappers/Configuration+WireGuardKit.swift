//
//  Configuration+WireGuardKit.swift
//  Partout
//
//  Created by Davide De Rosa on 11/23/21.
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

extension WireGuard.Configuration {
    init(wgQuickConfig: String) throws {
        let wg = try TunnelConfiguration(fromWgQuickConfig: wgQuickConfig)
        try self.init(wg: wg)
    }

    init(wg: TunnelConfiguration) throws {
        let interface = try WireGuard.LocalInterface(wg: wg.interface)
        let peers = try wg.peers.map {
            try WireGuard.RemoteInterface(wg: $0)
        }
        let builder = WireGuard.Configuration.Builder(
            interface: interface.builder(),
            peers: peers.map {
                $0.builder()
            }
        )
        self = try builder.tryBuild()
    }

    func toWireGuardConfiguration() throws -> TunnelConfiguration {
        let wgInterface = try interface.toWireGuardConfiguration()
        let wgPeers = try peers.map {
            try $0.toWireGuardConfiguration()
        }
        return TunnelConfiguration(name: nil, interface: wgInterface, peers: wgPeers)
    }

    func toWgQuickConfig() throws -> String {
        try toWireGuardConfiguration().asWgQuickConfig()
    }
}
