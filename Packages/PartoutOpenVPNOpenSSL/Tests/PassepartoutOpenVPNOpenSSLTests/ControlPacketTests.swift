//
//  ControlPacketTests.swift
//  Partout
//
//  Created by Davide De Rosa on 9/9/18.
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

final class ControlPacketTests: XCTestCase {
    func test_givenControlPacket_whenSerialize_thenIsExpected() {
        let id: UInt32 = 0x1456
        let code: PacketCode = .controlV1
        let key: UInt8 = 3
        let sessionId = Data(hex: "1122334455667788")
        let payload = Data(hex: "932748238742397591704891")

        let serialized = ControlPacket(
            code: code,
            key: key,
            sessionId: sessionId,
            packetId: id,
            payload: payload,
            ackIds: nil,
            ackRemoteSessionId: nil
        ).serialized()
        let expected = Data(hex: "2311223344556677880000001456932748238742397591704891")

        XCTAssertEqual(serialized, expected)
    }

    func test_givenAckPacket_whenSerialize_thenIsExpected() {
        let acks: [UInt32] = [0xaa, 0xbb, 0xcc, 0xdd, 0xee]
        let key: UInt8 = 3
        let sessionId = Data(hex: "1122334455667788")
        let remoteSessionId = Data(hex: "a639328cbf03490e")

        let serialized = ControlPacket(key: key, sessionId: sessionId, ackIds: acks as [NSNumber], ackRemoteSessionId: remoteSessionId).serialized()
        let expected = Data(hex: "2b112233445566778805000000aa000000bb000000cc000000dd000000eea639328cbf03490e")

        XCTAssertEqual(serialized, expected)
    }
}
