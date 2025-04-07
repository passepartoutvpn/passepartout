//
//  JSONTests.swift
//  Partout
//
//  Created by Davide De Rosa on 4/6/24.
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
@testable import PartoutOpenVPNOpenSSL
import XCTest

final class JSONTests: XCTestCase {
    func test_givenProtonVPN_whenConvertToJSON_thenFieldsExist() throws {
        let pair = try subjectPair(withSensitiveData: false)
        let sut = pair.json

        XCTAssertNotNil(sut["remotes"])
        XCTAssertNotNil(sut["randomizeEndpoint"])
        XCTAssertNotNil(sut["authUserPass"])
        XCTAssertNotNil(sut["renegotiatesAfter"])
        XCTAssertNotNil(sut["cipher"])
        XCTAssertNotNil(sut["digest"])
        XCTAssertNotNil(sut["ca"])
        XCTAssertNotNil(sut["tlsWrap"])
        XCTAssertNotNil(sut["xorMethod"])
        XCTAssertNotNil(sut["mtu"])
        XCTAssertNotNil(sut["checksEKU"])
        XCTAssertNil(sut["dnsServers"])
        XCTAssertNil(sut["clientCertificate"])
        XCTAssertNil(sut["clientKey"])
    }

    func test_givenProtonVPN_whenConvertToJSON_thenFieldsAreDisclosed() throws {
        let pair = try subjectPair(withSensitiveData: true)
        let sut = pair.json
        let cfg = pair.cfg

        XCTAssertEqual(sut["ca"] as? String, cfg.ca?.pem)

        let tlsWrap = try XCTUnwrap(sut["tlsWrap"] as? [String: Any])
        let tlsWrapKey = try XCTUnwrap(tlsWrap["key"] as? [String: Any])
        XCTAssertEqual(tlsWrapKey["data"] as? String, cfg.tlsWrap?.key.secureData.zData.toData().base64EncodedString())

        let xorMethod = try XCTUnwrap(sut["xorMethod"] as? [String: Any])
        let xorMethodObfuscate = try XCTUnwrap(xorMethod["obfuscate"] as? [String: Any])
        XCTAssertEqual(xorMethodObfuscate["mask"] as? String, cfg.xorMethod?.mask?.zData.toData().base64EncodedString())

        let remotes = try XCTUnwrap(sut["remotes"] as? [String])
        let rawRemotes = Set(remotes)
        let cfgRemotes = Set(cfg.remotes?.map(\.description) ?? [])
        XCTAssertEqual(rawRemotes, cfgRemotes)
    }

    func test_givenProtonVPN_whenConvertToSensitiveJSON_thenFieldsAreRedacted() throws {
        let pair = try subjectPair(withSensitiveData: false)
        let sut = pair.json

        XCTAssertEqual(sut["ca"] as? String, JSONEncoder.redactedValue)

        let tlsWrap = try XCTUnwrap(sut["tlsWrap"] as? [String: Any])
        let tlsWrapKey = try XCTUnwrap(tlsWrap["key"] as? [String: Any])
        XCTAssertEqual(tlsWrapKey["data"] as? String, JSONEncoder.redactedValue)

        let xorMethod = try XCTUnwrap(sut["xorMethod"] as? [String: Any])
        let xorMethodObfuscate = try XCTUnwrap(xorMethod["obfuscate"] as? [String: Any])
        XCTAssertEqual(xorMethodObfuscate["mask"] as? String, JSONEncoder.redactedValue)

        let remotes = try XCTUnwrap(sut["remotes"] as? [String])
        remotes.forEach {
            XCTAssertTrue($0.contains(JSONEncoder.redactedValue))
        }
    }
}

// MARK: - Helpers

private extension JSONTests {
    func subjectPair(withSensitiveData: Bool) throws -> (cfg: OpenVPN.Configuration, json: [String: Any]) {
        let parser = StandardOpenVPNParser()
        let url = try XCTUnwrap(Bundle.module.url(forResource: "protonvpn", withExtension: "ovpn"))
        let result = try parser.parsed(fromURL: url)
        let cfg = result.configuration

        let jsonString = try XCTUnwrap(cfg.asJSON(withSensitiveData: withSensitiveData))
        print(jsonString)
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))
        let json = try XCTUnwrap(try JSONSerialization.jsonObject(with: jsonData) as? [String: Any])

        return (cfg, json)
    }
}
