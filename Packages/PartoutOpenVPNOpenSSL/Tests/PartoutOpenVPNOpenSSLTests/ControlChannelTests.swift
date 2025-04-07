//
//  ControlChannelTests.swift
//  Partout
//
//  Created by Davide De Rosa on 7/7/18.
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
@testable import PartoutOpenVPNOpenSSL
import XCTest

@OpenVPNActor
final class ControlChannelTests: XCTestCase {
    func test_givenChannel_whenHandleSequence_thenIsReordered() {
        let seq1: [UInt32] = [0, 5, 2, 1, 4, 3]
        let seq2: [UInt32] = [5, 2, 1, 9, 4, 3, 0, 8, 7, 10, 4, 3, 5, 6]
        let seq3: [UInt32] = [5, 2, 11, 1, 2, 9, 4, 5, 5, 3, 8, 0, 6, 8, 2, 7, 10, 4, 3, 5, 6]

        for seq in [seq1, seq2, seq3] {
            XCTAssertEqual(
                seq.sorted().unique(),
                handledSequence(seq.map(Wrapper.init)).map(\.packetId)
            )
        }
    }
}

// MARK: - Helpers

private extension ControlChannelTests {
    func handledSequence(_ sequence: [Wrapper]) -> [Wrapper] {
        let sut = ControlChannel.self

        var queue: [Wrapper] = []
        var current: UInt32 = 0
        var handled: [Wrapper] = []
        for packet in sequence {
            sut.enqueueInbound(&queue, &current, packet) {
                handled.append($0)
            }
        }

        return handled
    }
}

final class Wrapper: PacketProtocol {
    var packetId: UInt32

    init(_ packetId: UInt32) {
        self.packetId = packetId
    }
}
