//
//  ZeroingDataTests.swift
//  Partout
//
//  Created by Davide De Rosa on 4/9/24.
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

internal import CPartoutCryptoOpenSSL
import Foundation
import PartoutCryptoOpenSSL
import XCTest

final class ZeroingDataTests: XCTestCase {
    func test_givenInput_whenInit_thenReturnsExpected() {
        XCTAssertEqual(ZeroingData(length: 123).length, 123)
        XCTAssertEqual(ZeroingData(bytes: [0x11, 0x22, 0x33, 0x44, 0x55], length: 3).length, 3)
        XCTAssertEqual(ZeroingData(uInt8: UInt8(78)).length, 1)
        XCTAssertEqual(ZeroingData(uInt16: UInt16(4756)).length, 2)
        XCTAssertEqual(ZeroingData(data: Data(count: 12)).length, 12)
        XCTAssertEqual(ZeroingData(data: Data(count: 12), offset: 3, length: 7).length, 7)
        XCTAssertEqual(ZeroingData(string: "hello", nullTerminated: false).length, 5)
        XCTAssertEqual(ZeroingData(string: "hello", nullTerminated: true).length, 6)
    }

    func test_givenData_whenOffset_thenReturnsExpected() {
        let sut = ZeroingData(string: "Hello", nullTerminated: true)
        XCTAssertEqual(sut.networkUInt16Value(fromOffset: 3), 0x6c6f)
        XCTAssertEqual(sut.nullTerminatedString(fromOffset: 0), "Hello")
        XCTAssertEqual(sut.withOffset(3, length: 2), ZeroingData(string: "lo", nullTerminated: false))
    }

    func test_givenData_whenAppend_thenIsAppended() {
        let sut = ZeroingData(string: "this_data", nullTerminated: false)
        let other = ZeroingData(string: "that_data", nullTerminated: false)

        let merged = sut.copy()
        merged.append(other)
        XCTAssertEqual(merged, ZeroingData(string: "this_datathat_data", nullTerminated: false))
        XCTAssertEqual(merged, sut.appending(other))
    }

    func test_givenData_whenTruncate_thenIsTruncated() {
        let data = Data(hex: "438ac4729847fb3975345983")
        let sut = ZeroingData(data: data)

        sut.truncate(toSize: 5)
        XCTAssertEqual(sut.length, 5)
        XCTAssertEqual(sut.toData(), data.subdata(in: 0..<5))
    }

    func test_givenData_whenRemove_thenIsRemoved() {
        let data = Data(hex: "438ac4729847fb3975345983")
        let sut = ZeroingData(data: data)

        sut.remove(untilOffset: 5)
        XCTAssertEqual(sut.length, data.count - 5)
        XCTAssertEqual(sut.toData(), data.subdata(in: 5..<data.count))
    }

    func test_givenData_whenZero_thenIsZeroedOut() {
        let data = Data(hex: "438ac4729847fb3975345983")
        let sut = ZeroingData(data: data)

        sut.zero()
        XCTAssertEqual(sut.length, data.count)
        XCTAssertEqual(sut.toData(), Data(repeating: 0, count: data.count))
    }

    func test_givenData_whenCompareEqual_thenIsEqual() {
        let data = Data(hex: "438ac4729847fb3975345983")
        let sut = ZeroingData(data: data)
        let other = ZeroingData(data: data)

        XCTAssertEqual(sut, other)
        XCTAssertEqual(sut, sut.copy())
        XCTAssertEqual(other, other.copy())
        XCTAssertEqual(sut.copy(), other.copy())

        sut.append(ZeroingData(length: 1))
        XCTAssertNotEqual(sut, other)
        other.append(ZeroingData(length: 1))
        XCTAssertEqual(sut, other)
    }

    func test_givenData_whenManipulate_thenDataIsExpected() {
        let z1 = ZeroingData()
        z1.append(ZeroingData(data: Data(hex: "12345678")))
        z1.append(ZeroingData(data: Data(hex: "abcdef")))
        let z2 = z1.withOffset(2, length: 3) // 5678ab
        let z3 = z2.appending(ZeroingData(data: Data(hex: "aaddcc"))) // 5678abaaddcc

        XCTAssertEqual(z1.toData(), Data(hex: "12345678abcdef"))
        XCTAssertEqual(z2.toData(), Data(hex: "5678ab"))
        XCTAssertEqual(z3.toData(), Data(hex: "5678abaaddcc"))
    }
}
