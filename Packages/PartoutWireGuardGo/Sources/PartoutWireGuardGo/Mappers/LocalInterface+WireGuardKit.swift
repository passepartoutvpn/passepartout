//
//  LocalInterface+WireGuardKit.swift
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

extension WireGuard.LocalInterface {
    init(wg: InterfaceConfiguration) throws {
        let wgPrivateKey = wg.privateKey.base64Key
        let addresses = wg.addresses.compactMap(Subnet.init(wg:))

        var dnsBuilder = DNSModule.Builder()
        dnsBuilder.servers = wg.dns.map(\.stringRepresentation)
        dnsBuilder.searchDomains = wg.dnsSearch
        let dns = try dnsBuilder.tryBuild()

        let mtu = wg.mtu

        guard let privateKey = WireGuard.Key(rawValue: wgPrivateKey) else {
            fatalError("Unable to build a WireGuard.Key from a PrivateKey?")
        }

        self.init(
            privateKey: privateKey,
            addresses: addresses,
            dns: dns,
            mtu: mtu
        )
    }

    func toWireGuardConfiguration() throws -> InterfaceConfiguration {
        guard let wgPrivateKey = PrivateKey(base64Key: privateKey.rawValue) else {
            throw PartoutError(.parsing)
        }
        var wg = InterfaceConfiguration(privateKey: wgPrivateKey)
        wg.addresses = try addresses.map {
            try $0.toWireGuardRange()
        }
        if let dns {
            wg.dns = try dns.servers.map {
                try $0.rawValue.toWireGuardDNS()
            }
            wg.dnsSearch = dns.searchDomains?.map(\.rawValue) ?? []
        }
        wg.mtu = mtu
        return wg
    }
}

extension String {
    func toWireGuardDNS() throws -> DNSServer {
        guard let wg = DNSServer(from: self) else {
            throw PartoutError(.parsing)
        }
        return wg
    }
}
