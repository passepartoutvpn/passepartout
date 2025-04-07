//
//  RemoteInterface+WireGuardKit.swift
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
import Network
import Partout
internal import WireGuardKit

extension WireGuard.RemoteInterface {
    init(wg: PeerConfiguration) throws {
        let wgPublicKey = wg.publicKey.base64Key
        let wgPreSharedKey = wg.preSharedKey?.base64Key

        let address: String?
        switch wg.endpoint?.host {
        case .ipv4(let nwAddress):
            address = nwAddress.debugDescription

        case .ipv6(let nwAddress):
            address = nwAddress.debugDescription

        case .name(let hostname, _):
            address = hostname

        default:
            address = nil
        }

        let endpoint: Partout.Endpoint?
        if let address,
           let addressObject = Address(rawValue: address),
           let port = wg.endpoint?.port.rawValue {
            endpoint = Partout.Endpoint(addressObject, port)
        } else {
            endpoint = nil
        }

        let allowedIPs = wg.allowedIPs.compactMap(Subnet.init(wg:))
        let keepAlive = wg.persistentKeepAlive

        guard let publicKey = WireGuard.Key(rawValue: wgPublicKey) else {
            fatalError("Unable to build a WireGuard.Key from a PublicKey?")
        }
        let preSharedKey = wgPreSharedKey.map {
            guard let key = WireGuard.Key(rawValue: $0) else {
                fatalError("Unable to build a WireGuard.Key from a PreSharedKey?")
            }
            return key
        }

        self.init(
            publicKey: publicKey,
            preSharedKey: preSharedKey,
            endpoint: endpoint,
            allowedIPs: allowedIPs,
            keepAlive: keepAlive
        )
    }

    func toWireGuardConfiguration() throws -> PeerConfiguration {
        guard let wgPublicKey = PublicKey(base64Key: publicKey.rawValue) else {
            throw PartoutError(.parsing)
        }
        var wg = PeerConfiguration(publicKey: wgPublicKey)
        if let preSharedKey {
            wg.preSharedKey = PreSharedKey(base64Key: preSharedKey.rawValue)
        }
        if let endpoint {
            wg.endpoint = try endpoint.toWireGuardEndpoint()
        }
        wg.allowedIPs = try allowedIPs.map {
            try $0.toWireGuardRange()
        }
        wg.persistentKeepAlive = keepAlive
        return wg
    }
}
