//
//  XORProcessorTests.swift
//  Partout
//
//  Created by Davide De Rosa on 11/4/22.
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
import Partout
@testable import PartoutOpenVPNOpenSSL
import XCTest

final class XORProcessorTests: XCTestCase {
    private let prng = SecureRandom()

    private let mask = SecureData("f76dab30")!

    func test_givenProcessor_whenMaskthenIsReversible() {
        let sut = XORProcessor(method: .xormask(mask: mask))
        sut.assertReversible(prng.data(length: 1000))
    }

    func test_givenProcessor_whenPtrPosthenIsReversible() {
        let sut = XORProcessor(method: .xorptrpos)
        sut.assertReversible(prng.data(length: 1000))
    }

    func test_givenProcessor_whenReversethenIsReversible() {
        let sut = XORProcessor(method: .reverse)
        sut.assertReversible(prng.data(length: 1000))
    }

    func test_givenProcessor_whenObfuscatethenIsReversible() {
        let sut = XORProcessor(method: .obfuscate(mask: mask))
        sut.assertReversible(prng.data(length: 1000))
    }

    func test_givenPacketStream_whenXORthenIsReversible() {
        let sut = prng.data(length: 10000)
        PacketStream.assertReversible(sut, method: .none)
        PacketStream.assertReversible(sut, method: .mask, mask: mask)
        PacketStream.assertReversible(sut, method: .ptrPos)
        PacketStream.assertReversible(sut, method: .reverse)
        PacketStream.assertReversible(sut, method: .obfuscate, mask: mask)
    }
}

// MARK: - Helpers

private extension XORProcessor {
    func assertReversible(_ data: Data) {
        let xorred = processPacket(data, outbound: true)
        XCTAssertEqual(processPacket(xorred, outbound: false), data)
    }
}

private extension PacketStream {
    static func assertReversible(_ data: Data, method: XORMethodNative, mask: SecureData? = nil) {
        var until = 0
        let outStream = PacketStream.outboundStream(fromPacket: data, xorMethod: method, xorMask: mask?.zData)
        let inStream = PacketStream.packets(fromInboundStream: outStream, until: &until, xorMethod: method, xorMask: mask?.zData)
        let originalData = Data(inStream.joined())
        XCTAssertEqual(data.toHex(), originalData.toHex())
    }
}
