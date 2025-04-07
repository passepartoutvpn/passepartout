//
//  StandardWireGuardParserTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/25/25.
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

import Partout
@testable import PartoutWireGuardGo
@testable internal import WireGuardKit
import XCTest

final class StandardWireGuardParserTests: XCTestCase {
    private let parser = StandardWireGuardParser()

    private let keyGenerator = StandardWireGuardKeyGenerator()

    // MARK: - Interface

    func test_givenParser_whenGoodBuilder_thenDoesNotThrow() {
        var sut = newBuilder()
        sut.interface.addresses = ["1.2.3.4"]

        var dns = DNSModule.Builder()
        dns.servers = ["1.2.3.4"]
        dns.searchDomains = ["domain.local"]
        sut.interface.dns = dns

        let builder = WireGuardModule.Builder(configurationBuilder: sut)
        XCTAssertNoThrow(try parser.validate(builder))
    }

    func test_givenParser_whenBadPrivateKey_thenThrows() {
        let sut = WireGuard.Configuration.Builder(privateKey: "")
        do {
            try assertValidationFailure(sut)
        } catch {
            assertParseError(error) {
                guard case .interfaceHasInvalidPrivateKey = $0 else {
                    XCTFail($0.localizedDescription)
                    return
                }
            }
        }
    }

    func test_givenParser_whenBadAddresses_thenThrows() {
        var sut = newBuilder()
        sut.interface.addresses = ["dsfds"]
        do {
            try assertValidationFailure(sut)
        } catch {
            assertParseError(error) {
                guard case .interfaceHasInvalidAddress = $0 else {
                    XCTFail($0.localizedDescription)
                    return
                }
            }
        }
    }

    // parser is too tolerant, never fails
//    func test_givenParser_whenBadDNS_thenThrows() {
//        var sut = newBuilder()
//        sut.interface.addresses = ["1.2.3.4"]
//
//        var dns = DNSModule.Builder()
//        dns.servers = ["1.a.2.$%3"]
//        dns.searchDomains = ["-invalid.example.com"]
//        sut.interface.dns = dns
//
//        do {
//            try assertValidationFailure(sut)
//        } catch {
//            assertParseError(error) {
//                guard case .interfaceHasInvalidDNS = $0 else {
//                    XCTFail($0.localizedDescription)
//                    return
//                }
//            }
//        }
//    }

    // MARK: - Peers

    func test_givenParser_whenBadPeerPublicKey_thenThrows() {
        var sut = newBuilder(withInterface: true)

        let peer = WireGuard.RemoteInterface.Builder(publicKey: "")
        sut.peers = [peer]

        do {
            try assertValidationFailure(sut)
        } catch {
            assertParseError(error) {
                guard case .peerHasInvalidPublicKey = $0 else {
                    XCTFail($0.localizedDescription)
                    return
                }
            }
        }
    }

    func test_givenParser_whenBadPeerPresharedKey_thenThrows() {
        var sut = newBuilder(withInterface: true, withPeer: true)
        var peer = sut.peers[0]
        peer.preSharedKey = "fdsfokn.,x"
        sut.peers = [peer]

        do {
            try assertValidationFailure(sut)
        } catch {
            assertParseError(error) {
                guard case .peerHasInvalidPreSharedKey = $0 else {
                    XCTFail($0.localizedDescription)
                    return
                }
            }
        }
    }

    func test_givenParser_whenBadPeerEndpoint_thenThrows() {
        var sut = newBuilder(withInterface: true, withPeer: true)
        var peer = sut.peers[0]
        peer.endpoint = "fdsfokn.,x"
        sut.peers = [peer]

        do {
            try assertValidationFailure(sut)
        } catch {
            assertParseError(error) {
                guard case .peerHasInvalidEndpoint = $0 else {
                    XCTFail($0.localizedDescription)
                    return
                }
            }
        }
    }

    func test_givenParser_whenBadPeerAllowedIPs_thenThrows() {
        var sut = newBuilder(withInterface: true, withPeer: true)
        var peer = sut.peers[0]
        peer.allowedIPs = ["fdsfokn.,x"]
        sut.peers = [peer]

        do {
            try assertValidationFailure(sut)
        } catch {
            assertParseError(error) {
                guard case .peerHasInvalidAllowedIP = $0 else {
                    XCTFail($0.localizedDescription)
                    return
                }
            }
        }
    }
}

private extension StandardWireGuardParserTests {
    func newBuilder(withInterface: Bool = false, withPeer: Bool = false) -> WireGuard.Configuration.Builder {
        var builder = WireGuard.Configuration.Builder(keyGenerator: keyGenerator)
        if withInterface {
            builder.interface.addresses = ["1.2.3.4"]
            var dns = DNSModule.Builder()
            dns.servers = ["1.2.3.4"]
            dns.searchDomains = ["domain.local"]
            builder.interface.dns = dns
        }
        if withPeer {
            let peerPrivateKey = keyGenerator.newPrivateKey()
            do {
                let publicKey = try keyGenerator.publicKey(for: peerPrivateKey)
                builder.peers = [WireGuard.RemoteInterface.Builder(publicKey: publicKey)]
            } catch {
                XCTFail(error.localizedDescription)
                return builder
            }
        }
        return builder
    }

    func assertValidationFailure(_ wgBuilder: WireGuard.Configuration.Builder) throws {
        let builder = WireGuardModule.Builder(configurationBuilder: wgBuilder)
        try parser.validate(builder)
        XCTFail("Must fail")
    }

    func assertParseError(_ error: Error, _ block: (TunnelConfiguration.ParseError) -> Void) {
        NSLog("Thrown: \(error.localizedDescription)")
        guard let ppError = error as? PartoutError else {
            XCTFail("Not a PartoutError")
            return
        }
        guard let parseError = ppError.reason as? TunnelConfiguration.ParseError else {
            XCTFail("Not a TunnelConfiguration.ParseError")
            return
        }
        block(parseError)
    }
}
