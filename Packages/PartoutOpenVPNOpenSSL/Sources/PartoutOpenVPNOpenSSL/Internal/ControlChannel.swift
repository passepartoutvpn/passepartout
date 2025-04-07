//
//  ControlChannel.swift
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
import Foundation
import Partout

@OpenVPNActor
final class ControlChannel {
    private let prng: PRNGProtocol

    private let serializer: ControlChannelSerializer

    private(set) var sessionId: Data?

    private(set) var remoteSessionId: Data? {
        didSet {
            if let id = remoteSessionId {
                pp_log(.openvpn, .info, "Control: Remote sessionId is \(id.toHex())")
            }
        }
    }

    private var queue: BidirectionalState<[ControlPacket]>

    private var currentPacketId: BidirectionalState<UInt32>

    private var pendingAcks: Set<UInt32>

    private var plainBuffer: ZeroingData

    private var sentDates: [UInt32: Date]

    convenience init(prng: PRNGProtocol) {
        self.init(prng: prng, serializer: PlainSerializer())
    }

    convenience init(
        prng: PRNGProtocol,
        crypto: OpenVPNCryptoProtocol,
        authKey key: OpenVPN.StaticKey,
        digest: OpenVPN.Digest
    ) throws {
        self.init(prng: prng, serializer: try AuthSerializer(with: crypto, key: key, digest: digest))
    }

    convenience init(
        prng: PRNGProtocol,
        crypto: OpenVPNCryptoProtocol,
        cryptKey key: OpenVPN.StaticKey
    ) throws {
        self.init(prng: prng, serializer: try CryptSerializer(with: crypto, key: key))
    }

    private init(prng: PRNGProtocol, serializer: ControlChannelSerializer) {
        self.prng = prng
        self.serializer = serializer
        sessionId = nil
        remoteSessionId = nil
        queue = BidirectionalState(withResetValue: [])
        currentPacketId = BidirectionalState(withResetValue: 0)
        pendingAcks = []
        plainBuffer = Z(length: OpenVPNTLSOptionsDefaultBufferLength)
        sentDates = [:]
    }
}

extension ControlChannel {
    func reset(forNewSession: Bool) {
        if forNewSession {
            sessionId = prng.data(length: PacketSessionIdLength)
            remoteSessionId = nil
        }
        queue.reset()
        currentPacketId.reset()
        pendingAcks.removeAll()
        plainBuffer.zero()
        sentDates.removeAll()
        serializer.reset()
    }

    func setRemoteSessionId(_ remoteSessionId: Data) {
        self.remoteSessionId = remoteSessionId
    }

    func readInboundPacket(withData data: Data, offset: Int) throws -> ControlPacket {
        do {
            let packet = try serializer.deserialize(data: data, start: offset, end: nil)
            pp_log(.openvpn, .info, "Control: Read packet \(packet.asSensitiveBytes)")
            if let ackIds = packet.ackIds as? [UInt32], let ackRemoteSessionId = packet.ackRemoteSessionId {
                try readAcks(ackIds, acksRemoteSessionId: ackRemoteSessionId)
            }
            return packet
        } catch {
            pp_log(.openvpn, .fault, "Control: Channel failure: \(error)")
            throw error
        }
    }

    func enqueueInboundPacket(packet: ControlPacket) -> [ControlPacket] {
        var toHandle: [ControlPacket] = []
        Self.enqueueInbound(&queue.inbound, &currentPacketId.inbound, packet) {
            toHandle.append($0)
        }
        return toHandle
    }

    static func enqueueInbound<T>(_ queue: inout [T], _ currentId: inout UInt32, _ packet: T, _ handle: (T) -> Void) where T: PacketProtocol {
        queue.append(packet)
        queue.sort {
            $0.packetId < $1.packetId
        }

        for packet in queue {
            if packet.packetId < currentId {
                queue.removeFirst()
                continue
            }
            if packet.packetId != currentId {
                return
            }

            handle(packet)
            currentId += 1
            queue.removeFirst()
        }
    }

    func enqueueOutboundPackets(withCode code: PacketCode, key: UInt8, payload: Data, maxPacketSize: Int) throws {
        guard let sessionId else {
            pp_log(.openvpn, .fault, "Control: Missing sessionId, do reset(forNewSession: true) first")
            throw OpenVPNSessionError.assertion
        }

        let oldIdOut = currentPacketId.outbound
        var queuedCount = 0
        var offset = 0

        repeat {
            let subPayloadLength = min(maxPacketSize, payload.count - offset)
            let subPayloadData = payload.subdata(offset: offset, count: subPayloadLength)
            let packet = ControlPacket(
                code: code,
                key: key,
                sessionId: sessionId,
                packetId: currentPacketId.outbound,
                payload: subPayloadData,
                ackIds: nil,
                ackRemoteSessionId: nil
            )

            queue.outbound.append(packet)
            currentPacketId.outbound += 1
            offset += maxPacketSize
            queuedCount += subPayloadLength
        } while offset < payload.count

        assert(queuedCount == payload.count)

        // packet count
        let packetCount = currentPacketId.outbound - oldIdOut
        if packetCount > 1 {
            pp_log(.openvpn, .info, "Control: Enqueued \(packetCount) packets [\(oldIdOut)-\(currentPacketId.outbound - 1)]")
        } else {
            pp_log(.openvpn, .info, "Control: Enqueued 1 packet [\(oldIdOut)]")
        }
    }

    func writeOutboundPackets(resendAfter: TimeInterval) throws -> [Data] {
        var rawList: [Data] = []
        for packet in queue.outbound {
            if let sentDate = sentDates[packet.packetId] {
                let timeAgo = -sentDate.timeIntervalSinceNow
                guard timeAgo >= resendAfter else {
                    pp_log(.openvpn, .info, "Control: Skip writing packet with packetId \(packet.packetId) (sent on \(sentDate), \(timeAgo) seconds ago < \(resendAfter))")
                    continue
                }
            }

            pp_log(.openvpn, .info, "Control: Write control packet \(packet.asSensitiveBytes)")

            let raw = try serializer.serialize(packet: packet)
            rawList.append(raw)
            sentDates[packet.packetId] = Date()

            // track pending acks for sent packets
            pendingAcks.insert(packet.packetId)
        }
        return rawList
    }

    func hasPendingAcks() -> Bool {
        !pendingAcks.isEmpty
    }

    private func readAcks(_ packetIds: [UInt32], acksRemoteSessionId: Data) throws {
        guard let sessionId = sessionId else {
            throw OpenVPNSessionError.missingSessionId
        }
        guard acksRemoteSessionId == sessionId else {
            let error = OpenVPNSessionError.sessionMismatch
            pp_log(.openvpn, .fault, "Control: Ack session mismatch (\(acksRemoteSessionId.toHex()) != \(sessionId.toHex())): \(error)")
            throw error
        }

        // drop queued out packets if ack-ed
        queue.outbound.removeAll {
            return packetIds.contains($0.packetId)
        }

        // remove ack-ed packets from pending
        pendingAcks.subtract(packetIds)
    }

    func writeAcks(withKey key: UInt8, ackPacketIds: [UInt32], ackRemoteSessionId: Data) throws -> Data {
        guard let sessionId = sessionId else {
            throw OpenVPNSessionError.missingSessionId
        }
        let packet = ControlPacket(key: key, sessionId: sessionId, ackIds: ackPacketIds as [NSNumber], ackRemoteSessionId: ackRemoteSessionId)
        pp_log(.openvpn, .info, "Control: Write ack packet \(packet.asSensitiveBytes)")
        return try serializer.serialize(packet: packet)
    }

    func currentControlData(withTLS tls: OpenVPNTLSProtocol) throws -> ZeroingData {
        var length = 0
        try tls.pullRawPlainText(plainBuffer.mutableBytes, length: &length)
        return plainBuffer.withOffset(0, length: length)
    }
}
