//
//  OpenVPNSession+Loop.swift
//  Partout
//
//  Created by Davide De Rosa on 3/28/24.
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

// TODO: #197, LINK and TUN should be able to run detached in full-duplex
extension OpenVPNSession {
    func loopTunnel() {
        runInActor { [weak self] in
            guard let self, let tunnel else {
                pp_log(.openvpn, .info, "Ignore read from outdated TUN")
                return
            }
            do {
                let packets = try await tunnel.readPackets()
                guard !packets.isEmpty else {
                    return
                }
                try receiveTunnel(packets: packets)
            } catch {
                pp_log(.openvpn, .error, "Failed TUN read: \(error)")
                await shutdown(error)
            }

            // repeat as long as self and tunnel exist
            loopTunnel()
        }
    }

    func loopLink() {
        link?.setReadHandler { [weak self] packets, error in
            self?.runInActor { [weak self] in
                guard let self else {
                    pp_log(.openvpn, .info, "Ignore read from outdated LINK")
                    return
                }
                if let error {
                    pp_log(.openvpn, .error, "Failed LINK read: \(error)")
                    await shutdown(PartoutError(.linkFailure, error))
                }
                guard let packets, !packets.isEmpty else {
                    return
                }
                do {
                    try receiveLink(packets: packets)
                } catch {
                    await shutdown(error)
                }
            }
        }
    }
}

// MARK: - Private

private extension OpenVPNSession {
    func receiveLink(packets: [Data]) throws {
        guard !isStopped, let link else {
            return
        }

        reportLastReceivedDate()
        var dataPacketsByKey: [UInt8: [Data]] = [:]

        guard var negotiator = currentNegotiator else {
            pp_log(.openvpn, .fault, "No negotiator")
            throw OpenVPNSessionError.assertion
        }
        if negotiator.shouldRenegotiate() {
            negotiator = try startRenegotiation(after: negotiator, on: link, isServerInitiated: false)
        }

        for packet in packets {
            guard let firstByte = packet.first else {
                pp_log(.openvpn, .error, "Dropped malformed packet (missing opcode)")
                continue
            }
            let codeValue = firstByte >> 3
            guard let code = PacketCode(rawValue: codeValue) else {
                pp_log(.openvpn, .error, "Dropped malformed packet (unknown code: \(codeValue))")
                continue
            }

            var offset = 1
            if code == .dataV2 {
                guard packet.count >= offset + PacketPeerIdLength else {
                    pp_log(.openvpn, .error, "Dropped malformed packet (missing peerId)")
                    continue
                }
                offset += PacketPeerIdLength
            }

            if code == .dataV1 || code == .dataV2 {
                let key = firstByte & 0b111
                guard hasDataChannel(for: key) else {
                    pp_log(.openvpn, .error, "Data: Channel with key \(key) not found")
                    continue
                }

                // TODO: #225, make more efficient with array reference
                var dataPackets = dataPacketsByKey[key] ?? [Data]()
                dataPackets.append(packet)
                dataPacketsByKey[key] = dataPackets

                continue
            }

            let controlPacket: ControlPacket
            do {
                let parsedPacket = try negotiator.readInboundPacket(withData: packet, offset: 0)
                negotiator.handleAcks()
                if parsedPacket.code == .ackV1 {
                    continue
                }
                controlPacket = parsedPacket
            } catch {
                pp_log(.openvpn, .error, "Dropped malformed packet: \(error)")
                continue
            }
            switch code {
            case .hardResetServerV2:

                // HARD_RESET coming while connected
                guard !negotiator.isConnected else {
                    throw OpenVPNSessionError.recoverable(OpenVPNSessionError.staleSession)
                }

            case .softResetV1:
                if !negotiator.isRenegotiating {
                    negotiator = try startRenegotiation(after: negotiator, on: link, isServerInitiated: true)
                }

            default:
                break
            }

            negotiator.sendAck(for: controlPacket, to: link)

            let pendingInboundQueue = negotiator.enqueueInboundPacket(packet: controlPacket)
            pp_log(.openvpn, .debug, "Pending inbound queue: \(pendingInboundQueue.map(\.packetId))")
            for inboundPacket in pendingInboundQueue {
                pp_log(.openvpn, .debug, "Handle packet: \(inboundPacket.packetId)")
                try negotiator.handleControlPacket(inboundPacket)
            }
        }

        // send decrypted packets to tunnel all at once
        if let tunnel {
            for (key, dataPackets) in dataPacketsByKey {
                guard let dataChannel = dataChannel(for: key) else {
                    pp_log(.openvpn, .error, "Accounted a data packet for which the cryptographic key hadn't been found")
                    continue
                }
                handleDataPackets(
                    dataPackets,
                    to: tunnel,
                    dataChannel: dataChannel
                )
            }
        }
    }

    func receiveTunnel(packets: [Data]) throws {
        guard !isStopped else {
            return
        }
        guard let negotiator = currentNegotiator else {
            pp_log(.openvpn, .fault, "No negotiator")
            throw OpenVPNSessionError.assertion
        }
        guard negotiator.isConnected, let currentDataChannel else {
            return
        }

        try checkPingTimeout()

        sendDataPackets(
            packets,
            to: negotiator.link,
            dataChannel: currentDataChannel
        )
    }
}
