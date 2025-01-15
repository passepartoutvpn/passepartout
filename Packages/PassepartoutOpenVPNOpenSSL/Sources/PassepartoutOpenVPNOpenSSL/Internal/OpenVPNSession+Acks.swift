//
//  OpenVPNSession+Acks.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 3/28/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

internal import CPassepartoutOpenVPNOpenSSL
import Foundation
import PassepartoutKit

extension OpenVPNSession {
    func handleAcks() {
        //
    }

    func sendAck(
        for controlPacket: ControlPacket,
        to link: LinkInterface,
        channel: ControlChannel
    ) async throws {
        do {
            pp_log(.openvpn, .info, "Send ack for received packetId \(controlPacket.packetId)")
            let raw = try await channel.writeAcks(
                withKey: controlPacket.key,
                ackPacketIds: [controlPacket.packetId],
                ackRemoteSessionId: controlPacket.sessionId
            )
            try await link.writePackets([raw])
            pp_log(.openvpn, .info, "Ack successfully written to LINK for packetId \(controlPacket.packetId)")
        } catch {
            pp_log(.openvpn, .error, "Failed LINK write during send ack for packetId \(controlPacket.packetId): \(error)")
            throw PassepartoutError(.linkFailure)
        }
    }
}
