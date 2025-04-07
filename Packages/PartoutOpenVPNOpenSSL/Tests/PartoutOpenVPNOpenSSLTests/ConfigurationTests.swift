//
//  ConfigurationTests.swift
//  Partout
//
//  Created by Davide De Rosa on 10/17/22.
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

@testable import PartoutOpenVPNOpenSSL
import Partout
import XCTest

final class ConfigurationTests: XCTestCase {
    func test_givenRandomizeHostnames_whenProcessRemotes_thenHostnamesHaveAlphanumericPrefix() throws {
        var builder = OpenVPN.Configuration.Builder()
        let hostname = "my.host.name"
        let ipv4 = "1.2.3.4"
        builder.remotes = [
            try? ExtendedEndpoint(hostname, .init(.udp, 1111)),
            try? ExtendedEndpoint(ipv4, .init(.udp4, 3333))
        ].compactMap { $0 }
        builder.randomizeHostnames = true
        let cfg = try builder.tryBuild(isClient: false)

        cfg.processedRemotes(prng: MockPRNG())?
            .forEach {
                let comps = $0.address.rawValue.components(separatedBy: ".")
                guard let first = comps.first else {
                    XCTFail()
                    return
                }
                if $0.isHostname {
                    XCTAssert($0.address.rawValue.hasSuffix(hostname))
                    XCTAssertEqual(first.count, 12)
                    XCTAssertTrue(first.allSatisfy("0123456789abcdef".contains))
                } else {
                    XCTAssertEqual($0.address.rawValue, ipv4)
                }
            }
    }
}

private final class MockPRNG: PRNGProtocol {
    func uint32() -> UInt32 {
        1
    }

    func data(length: Int) -> Data {
        Data(Array(repeating: 1, count: length))
    }

    func safeData(length: Int) -> SecureData {
        SecureData(data(length: length))
    }
}
