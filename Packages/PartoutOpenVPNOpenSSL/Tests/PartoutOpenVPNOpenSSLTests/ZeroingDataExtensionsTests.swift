//
//  ZeroingDataExtensionsTests.swift
//  Partout
//
//  Created by Davide De Rosa on 1/14/25.
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

final class ZeroingDataExtensionsTests: XCTestCase {
    func test_givenPRNG_whenGenerateSafeData_thenHasGivenLength() {
        let sut = SecureRandom()
        XCTAssertEqual(sut.safeData(length: 500).length, 500)
    }

    func test_givenZeroingData_whenAsSensitive_thenOmitsSensitiveData() throws {
        let sut = Z(Data(hex: "12345678abcdef"))
        XCTAssertEqual(sut.debugDescription(withSensitiveData: true), "[7 bytes, 12345678abcdef]")
        XCTAssertEqual(sut.debugDescription(withSensitiveData: false), "[7 bytes]")
    }
}
