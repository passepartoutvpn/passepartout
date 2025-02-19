//
//  MappersTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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
@testable import PassepartoutWireGuardGo
internal import WireGuardKit
import XCTest

final class MappersTests: XCTestCase {
    func test_givenEndpointString_whenMapped_thenReverts() throws {
        let sut = [
            "1.2.3.4:10000",
            "[1:2:3::4]:10000"
        ]
        let expected: [(String, UInt16)] = [
            ("1.2.3.4", 10000),
            ("1:2:3::4", 10000)
        ]
        for (i, raw) in sut.enumerated() {
            let wg = try XCTUnwrap(WireGuardKit.Endpoint(from: raw))
            let kit = try XCTUnwrap(PassepartoutKit.Endpoint(wg: wg))
            try XCTAssertEqual(wg, kit.toWireGuardEndpoint(), "Index \(i) failed")

            let pair = expected[i]
            XCTAssertEqual(wg.host.debugDescription, pair.0)
            XCTAssertEqual(wg.port.rawValue, pair.1)
            XCTAssertEqual(kit.address.rawValue, pair.0)
            XCTAssertEqual(kit.port, pair.1)
        }
    }

    func test_givenConfigurationWithAllowedIPs_whenMapped_thenReverts() throws {
        let quickConfig = """
[Interface]
PrivateKey = 4hBza7JtPKZFKwqtEmDR0iZyru1kqpQta/DRduMbHQw=
Address = 10.8.0.6/24
DNS = 1.1.1.1

[Peer]
PublicKey = muwialz9E36nXp9qgbGIxwMrH+5Ovr8d7cutH8JHdvE=
PresharedKey = 4hBza7JtPKZFKwqtEmDR0iZyru1kqpQta/DRduMbHQw=
AllowedIPs = 8.8.4.0/24, 8.8.8.0/24, 8.34.208.0/20, 8.35.192.0/20, 23.236.48.0/20, 23.251.128.0/19, 212.188.34.209/32, 172.217.169.138/32, 142.250.187.106/32, 142.250.186.33/32, 172.217.17.23/32
PersistentKeepalive = 0
Endpoint = 1.2.3.4:12345
"""
        let wg = try TunnelConfiguration(fromWgQuickConfig: quickConfig)
        let sut = try WireGuard.Configuration(wg: wg)

        XCTAssertEqual(try sut.interface.toWireGuardConfiguration(), wg.interface)
        try sut.peers.enumerated().forEach { i, peer in
            XCTAssertEqual(try peer.toWireGuardConfiguration(), wg.peers[i])
        }

        XCTAssertEqual(wg, try sut.toWireGuardConfiguration())
    }
}
