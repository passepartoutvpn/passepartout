//
//  OSSLTLSBoxTests.swift
//  Partout
//
//  Created by Davide De Rosa on 3/20/24.
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
import XCTest

final class OSSLTLSBoxTests: XCTestCase {
    func test_givenCertificate_whenComputeMD5_thenChecksumIsCorrect() throws {
        let sut = OSSLTLSBox()
        let path = try XCTUnwrap(Bundle.module.path(forResource: "pia-2048", ofType: "pem"))
        let checksum = try sut.md5(forCertificatePath: path)
        let expected = "e2fccccaba712ccc68449b1c56427ac1"
        XCTAssertEqual(checksum, expected)
    }
}
