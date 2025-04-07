//
//  StandardOpenVPNOpenSSLParserTests.swift
//  Partout
//
//  Created by Davide De Rosa on 11/10/18.
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

internal import CPartoutOpenVPNOpenSSL
import PartoutOpenVPNOpenSSL
import XCTest

final class StandardOpenVPNOpenSSLParserTests: XCTestCase {
    func test_givenPKCS1_whenParse_thenFails() {
        let sut = newParser()
        let cfgURL = url(withName: "tunnelbear.enc.1")
        XCTAssertThrowsError(try sut.parsed(fromURL: cfgURL))
    }

    func test_givenPKCS1_whenParseWithPassphrase_thenSucceeds() {
        let sut = newParser()
        let cfgURL = url(withName: "tunnelbear.enc.1")
        XCTAssertNoThrow(try sut.parsed(fromURL: cfgURL, passphrase: "foobar"))
    }

    func test_givenPKCS8_whenParse_thenFails() {
        let sut = newParser()
        let cfgURL = url(withName: "tunnelbear.enc.8")
        XCTAssertThrowsError(try sut.parsed(fromURL: cfgURL))
    }

    func test_givenPKCS8_whenParseWithPassphrase_thenSucceeds() {
        let sut = newParser()
        let cfgURL = url(withName: "tunnelbear.enc.8")
        XCTAssertThrowsError(try sut.parsed(fromURL: cfgURL))
        XCTAssertNoThrow(try sut.parsed(fromURL: cfgURL, passphrase: "foobar"))
    }
}

private extension StandardOpenVPNOpenSSLParserTests {
    func newParser() -> StandardOpenVPNParser {
        StandardOpenVPNParser(decrypter: OSSLTLSBox())
    }

    func url(withName name: String) -> URL {
        Bundle.module.url(forResource: name, withExtension: "ovpn")!
    }
}
