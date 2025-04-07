//
//  Negotiator.swift
//  Partout
//
//  Created by Davide De Rosa on 4/12/17.
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
final class Negotiator {
    struct Options {
        let configuration: OpenVPN.Configuration

        let credentials: OpenVPN.Credentials?

        let withLocalOptions: Bool

        let sessionOptions: OpenVPN.ConnectionOptions

        let tlsOptions: OpenVPNTLSOptions

        let onConnected: (UInt8, DataChannel, PushReply) async -> Void

        let onError: (UInt8, Error) async -> Void
    }

    private let parser = StandardOpenVPNParser()

    let key: UInt8 // 3-bit

    private(set) var history: NegotiationHistory?

    private let renegotiation: RenegotiationType?

    let link: LinkInterface

    private var channel: ControlChannel

    private let prng: PRNGProtocol

    private let tlsFactory: () -> OpenVPNTLSProtocol

    private let cryptoFactory: () -> OpenVPNCryptoProtocol

    private let options: Options

    // MARK: State

    private let startTime: Date

    private let negotiationTimeout: TimeInterval

    private var state: State {
        didSet {
            pp_log(.openvpn, .info, "Negotiator: \(key) -> \(state)")
        }
    }

    private let tlsBox: OpenVPNTLSProtocol

    private var expectedPacketId: UInt32

    private var pendingPackets: [UInt32: ControlPacket]

    private var authenticator: Authenticator?

    private var nextPushRequestDate: Date?

    private var continuatedPushReplyMessage: String?

    private var checkNegotiationTask: Task<Void, Never>?

    // MARK: Init

    convenience init(
        link: LinkInterface,
        channel: ControlChannel,
        prng: PRNGProtocol,
        tlsFactory: @escaping () -> OpenVPNTLSProtocol,
        cryptoFactory: @escaping () -> OpenVPNCryptoProtocol,
        options: Options
    ) {
        self.init(
            key: 0,
            history: nil,
            renegotiation: nil,
            link: link,
            channel: channel,
            prng: prng,
            tlsFactory: tlsFactory,
            cryptoFactory: cryptoFactory,
            options: options
        )
    }

    private init(
        key: UInt8,
        history: NegotiationHistory?,
        renegotiation: RenegotiationType?,
        link: LinkInterface,
        channel: ControlChannel, // TODO: #196, abstract this for testing
        prng: PRNGProtocol,
        tlsFactory: @escaping () -> OpenVPNTLSProtocol,
        cryptoFactory: @escaping () -> OpenVPNCryptoProtocol,
        options: Options
    ) {
        self.key = key
        self.history = history
        self.renegotiation = renegotiation
        self.link = link
        self.channel = channel
        self.prng = prng
        self.tlsFactory = tlsFactory
        self.cryptoFactory = cryptoFactory
        self.options = options

        startTime = Date()
        negotiationTimeout = renegotiation != nil ? options.sessionOptions.softNegotiationTimeout : options.sessionOptions.negotiationTimeout
        state = .idle
        tlsBox = tlsFactory()
        expectedPacketId = 0
        pendingPackets = [:]
    }

    func forRenegotiation(initiatedBy newRenegotiation: RenegotiationType) -> Negotiator {
        guard let history else {
            pp_log(.openvpn, .error, "Negotiator has no history (not connected yet?)")
            return self
        }
        let newKey = ProtocolMacros.nextKey(after: key)
        return Negotiator(
            key: newKey,
            history: history,
            renegotiation: newRenegotiation,
            link: link,
            channel: channel,
            prng: prng,
            tlsFactory: tlsFactory,
            cryptoFactory: cryptoFactory,
            options: options
        )
    }
}

// MARK: - Public API

extension Negotiator {
    var isConnected: Bool {
        state == .connected
    }

    var isRenegotiating: Bool {
        renegotiation != nil && state != .connected
    }

    func start() throws {
        channel.reset(forNewSession: renegotiation == nil)

        // schedule this repeatedly
        try checkNegotiationComplete()

        switch renegotiation {
        case .client:
            try enqueueControlPackets(code: .softResetV1, key: key, payload: Data())

        case .server:
            break

        default:
            try enqueueControlPackets(code: .hardResetClientV2, key: key, payload: hardResetPayload() ?? Data())
        }
    }

    func cancel() {
        checkNegotiationTask?.cancel()
    }

    func readInboundPacket(withData packet: Data, offset: Int) throws -> ControlPacket {
        try channel.readInboundPacket(withData: packet, offset: 0)
    }

    func enqueueInboundPacket(packet controlPacket: ControlPacket) -> [ControlPacket] {
        channel.enqueueInboundPacket(packet: controlPacket)
    }

    func handleControlPacket(_ packet: ControlPacket) throws {
        guard packet.packetId >= expectedPacketId else {
            return
        }
        if packet.packetId > expectedPacketId {
            pendingPackets[packet.packetId] = packet
            return
        }

        try privateHandleControlPacket(packet)
        expectedPacketId += 1

        while let packet = pendingPackets[expectedPacketId] {
            try privateHandleControlPacket(packet)
            pendingPackets.removeValue(forKey: packet.packetId)
            expectedPacketId += 1
        }
    }

    func handleAcks() {
        //
    }

    func sendAck(for controlPacket: ControlPacket, to link: LinkInterface) {
        Task {
            try await privateSendAck(for: controlPacket, to: link)
        }
    }

    func shouldRenegotiate() -> Bool {
        guard state == .connected else {
            return false
        }
        guard let renegotiatesAfter = options.configuration.renegotiatesAfter, renegotiatesAfter > 0 else {
            return false
        }
        return elapsedSinceStart >= renegotiatesAfter
    }
}

// MARK: - Outbound

private extension Negotiator {
    func hardResetPayload() -> Data? {
        if options.configuration.usesPIAPatches ?? false {
            guard let caURL = tlsBox.options()?.caURL() else {
                return nil
            }
            do {
                let caMD5 = try tlsBox.md5(forCertificatePath: caURL.path)
                pp_log(.openvpn, .info, "PIA CA MD5 is: \(caMD5)")
                return try? PIAHardReset(
                    caMd5Digest: caMD5,
                    cipher: options.configuration.fallbackCipher,
                    digest: options.configuration.fallbackDigest
                ).encodedData(prng: prng)
            } catch {
                pp_log(.openvpn, .error, "PIA CA MD5 could not be computed, skip custom HARD_RESET")
                return nil
            }
        }
        return nil
    }

    func checkNegotiationComplete() throws {
        guard !didHardResetTimeout else {
            throw OpenVPNSessionError.recoverable(OpenVPNSessionError.negotiationTimeout)
        }
        guard !didNegotiationTimeout else {
            throw OpenVPNSessionError.negotiationTimeout
        }

        if !isRenegotiating {
            try pushRequest()
        }
        if !link.isReliable {
            try flushControlQueue()
        }

        guard state == .connected else {
            checkNegotiationTask?.cancel()
            checkNegotiationTask = Task { [weak self] in
                guard let self else {
                    return
                }
                try? await Task.sleep(milliseconds: Int(options.sessionOptions.tickInterval * 1000))
                guard !Task.isCancelled else {
                    return
                }
                do {
                    try checkNegotiationComplete()
                } catch {
                    await options.onError(key, error)
                }
            }
            return
        }

        // let loop die when negotiation is complete
    }

    func pushRequest() throws {
        guard state == .push else {
            return
        }
        guard let nextPushRequestDate, Date() > nextPushRequestDate else {
            return
        }

        pp_log(.openvpn, .info, "TLS.ifconfig: Put plaintext (PUSH_REQUEST)")
        try? tlsBox.putPlainText("PUSH_REQUEST\0")

        let cipherTextOut: Data
        do {
            cipherTextOut = try tlsBox.pullCipherText()
        } catch {
            if let nativeError = error.asNativeOpenVPNError {
                pp_log(.openvpn, .fault, "TLS.auth: Failed pulling ciphertext: \(nativeError)")
                throw nativeError
            }
            pp_log(.openvpn, .debug, "TLS.ifconfig: Still can't pull ciphertext")
            return
        }

        pp_log(.openvpn, .info, "TLS.ifconfig: Send pulled ciphertext \(cipherTextOut.asSensitiveBytes)")
        try enqueueControlPackets(code: .controlV1, key: key, payload: cipherTextOut)

        self.nextPushRequestDate = Date().addingTimeInterval(options.sessionOptions.pushRequestInterval)
    }

    func enqueueControlPackets(code: PacketCode, key: UInt8, payload: Data) throws {
        try channel.enqueueOutboundPackets(
            withCode: code,
            key: key,
            payload: payload,
            maxPacketSize: Constants.maxPacketSize
        )
        try flushControlQueue()
    }

    func flushControlQueue() throws {
        let rawList: [Data]
        do {
            rawList = try channel.writeOutboundPackets(resendAfter: options.sessionOptions.retxInterval)
        } catch {
            pp_log(.openvpn, .error, "Failed control packet serialization: \(error)")
            throw error
        }
        guard !rawList.isEmpty else {
            return
        }
        for raw in rawList {
            pp_log(.openvpn, .info, "Send control packet \(raw.asSensitiveBytes)")
        }
        Task {
            do {
                try await link.writePackets(rawList)
            } catch {
                pp_log(.openvpn, .error, "Failed LINK write during control flush: \(error)")
                await options.onError(key, PartoutError(.linkFailure, error))
            }
        }
    }
}

// MARK: - Inbound

private extension Negotiator {
    func privateHandleControlPacket(_ packet: ControlPacket) throws {
        guard packet.key == key else {
            pp_log(.openvpn, .error, "Bad key in control packet (\(packet.key) != \(key))")
            return
        }

        switch state {
        case .idle:
            guard packet.code == .hardResetServerV2 || packet.code == .softResetV1 else {
                break
            }
            if packet.code == .hardResetServerV2 {
                if isRenegotiating {
                    pp_log(.openvpn, .error, "Sent SOFT_RESET but received HARD_RESET?")
                }
                channel.setRemoteSessionId(packet.sessionId)
            }
            guard let remoteSessionId = channel.remoteSessionId else {
                let error = OpenVPNSessionError.missingSessionId
                pp_log(.openvpn, .fault, "No remote sessionId (never set): \(error)")
                throw error
            }
            guard packet.sessionId == remoteSessionId else {
                let error = OpenVPNSessionError.sessionMismatch
                pp_log(.openvpn, .fault, "Packet session mismatch (\(packet.sessionId.toHex()) != \(remoteSessionId.toHex())): \(error)")
                throw error
            }

            pp_log(.openvpn, .info, "Start TLS handshake")
            state = .tls

            try tlsBox.configure(with: options.tlsOptions) { [weak self] error in
                guard let self else {
                    return
                }
                Task {
                    await self.options.onError(self.key, error)
                }
            }
            try tlsBox.start()

            let cipherTextOut: Data
            do {
                cipherTextOut = try tlsBox.pullCipherText()
            } catch {
                if let nativeError = error.asNativeOpenVPNError {
                    pp_log(.openvpn, .fault, "TLS.connect: Failed pulling ciphertext: \(nativeError)")
                    throw nativeError
                }
                throw error
            }

            pp_log(.openvpn, .info, "TLS.connect: Pulled ciphertext \(cipherTextOut.asSensitiveBytes)")
            try enqueueControlPackets(code: .controlV1, key: key, payload: cipherTextOut)

        case .tls, .auth, .push, .connected:
            guard packet.code == .controlV1 else {
                return
            }
            guard let remoteSessionId = channel.remoteSessionId else {
                let error = OpenVPNSessionError.missingSessionId
                pp_log(.openvpn, .fault, "No remote sessionId found in packet (control packets before server HARD_RESET): \(error)")
                throw error
            }
            guard packet.sessionId == remoteSessionId else {
                let error = OpenVPNSessionError.sessionMismatch
                pp_log(.openvpn, .fault, "Packet session mismatch (\(packet.sessionId.toHex()) != \(remoteSessionId.toHex())): \(error)")
                throw error
            }
            guard let cipherTextIn = packet.payload else {
                pp_log(.openvpn, .error, "TLS.connect: Control packet with empty payload?")
                return
            }

            pp_log(.openvpn, .info, "TLS.connect: Put received ciphertext [\(packet.packetId)] \(cipherTextIn.asSensitiveBytes)")
            try? tlsBox.putCipherText(cipherTextIn)

            let cipherTextOut: Data
            do {
                cipherTextOut = try tlsBox.pullCipherText()
                pp_log(.openvpn, .info, "TLS.connect: Send pulled ciphertext \(cipherTextOut.asSensitiveBytes)")
                try enqueueControlPackets(code: .controlV1, key: key, payload: cipherTextOut)
            } catch {
                if let nativeError = error.asNativeOpenVPNError {
                    pp_log(.openvpn, .fault, "TLS.connect: Failed pulling ciphertext: \(nativeError)")
                    throw nativeError
                }
                pp_log(.openvpn, .debug, "TLS.connect: No available ciphertext to pull")
            }

            if state < .auth, tlsBox.isConnected() {
                pp_log(.openvpn, .info, "TLS.connect: Handshake is complete")
                state = .auth

                try onTLSConnect()
            }
            do {
                while true {
                    let controlData = try channel.currentControlData(withTLS: tlsBox)
                    try handleControlData(controlData)
                }
            } catch {
            }
        }
    }

    func privateSendAck(for controlPacket: ControlPacket, to link: LinkInterface) async throws {
        do {
            pp_log(.openvpn, .info, "Send ack for received packetId \(controlPacket.packetId)")
            let raw = try channel.writeAcks(
                withKey: controlPacket.key,
                ackPacketIds: [controlPacket.packetId],
                ackRemoteSessionId: controlPacket.sessionId
            )
            try await link.writePackets([raw])
            pp_log(.openvpn, .info, "Ack successfully written to LINK for packetId \(controlPacket.packetId)")
        } catch {
            pp_log(.openvpn, .error, "Failed LINK write during send ack for packetId \(controlPacket.packetId): \(error)")
            await options.onError(key, PartoutError(.linkFailure, error))
        }
    }

    func onTLSConnect() throws {
        authenticator = Authenticator(
            prng: prng,
            options.credentials?.username,
            history?.pushReply.options.authToken ?? options.credentials?.password
        )
        authenticator?.withLocalOptions = options.withLocalOptions
        try authenticator?.putAuth(into: tlsBox, options: options.configuration)

        let cipherTextOut: Data
        do {
            cipherTextOut = try tlsBox.pullCipherText()
        } catch {
            if let nativeError = error.asNativeOpenVPNError {
                pp_log(.openvpn, .fault, "TLS.auth: Failed pulling ciphertext: \(nativeError)")
                throw nativeError
            }
            pp_log(.openvpn, .debug, "TLS.auth: Still can't pull ciphertext")
            return
        }

        pp_log(.openvpn, .info, "TLS.auth: Pulled ciphertext \(cipherTextOut.asSensitiveBytes)")
        try enqueueControlPackets(code: .controlV1, key: key, payload: cipherTextOut)
    }

    func handleControlData(_ data: ZeroingData) throws {
        guard let authenticator else {
            return
        }

        pp_log(.openvpn, .info, "Pulled plain control data \(data.asSensitiveBytes)")
        authenticator.appendControlData(data)

        if state == .auth {
            guard try authenticator.parseAuthReply() else {
                return
            }

            // renegotiation goes straight to .connected
            guard !isRenegotiating else {
                state = .connected
                guard let pushReply = history?.pushReply else {
                    pp_log(.openvpn, .fault, "Renegotiating connection without former history")
                    throw OpenVPNSessionError.assertion
                }
                try completeConnection(pushReply: pushReply)
                return
            }

            state = .push
            nextPushRequestDate = Date().addingTimeInterval(options.sessionOptions.retxInterval)
        }

        for message in authenticator.parseMessages() {
            pp_log(.openvpn, .info, "Parsed control message \(message.asSensitiveBytes)")
            do {
                try handleControlMessage(message)
            } catch {
                Task {
                    await options.onError(key, error)
                }
                throw error
            }
        }
    }

    func handleControlMessage(_ message: String) throws {
        pp_log(.openvpn, .info, "Received control message \(message.asSensitiveBytes)")

        // disconnect on authentication failure
        guard !message.hasPrefix("AUTH_FAILED") else {

            // XXX: retry without client options
            if authenticator?.withLocalOptions ?? false {
                pp_log(.openvpn, .error, "Authentication failure, retry without local options")
                throw OpenVPNSessionError.badCredentialsWithLocalOptions
            }

            throw OpenVPNSessionError.badCredentials
        }

        // disconnect on remote server restart (--explicit-exit-notify)
        guard !message.hasPrefix("RESTART") else {
            pp_log(.openvpn, .info, "Disconnect due to server shutdown")
            throw OpenVPNSessionError.serverShutdown
        }

        // handle authentication from now on
        guard state == .push else {
            return
        }

        let completeMessage: String
        if let continuatedPushReplyMessage {
            completeMessage = "\(continuatedPushReplyMessage),\(message)"
        } else {
            completeMessage = message
        }
        let reply: PushReply
        do {
            guard let optionalReply = try parser.pushReply(with: completeMessage) else {
                return
            }
            reply = optionalReply
            pp_log(.openvpn, .info, "Received PUSH_REPLY: \"\(reply)\"")

            if let framing = reply.options.compressionFraming, let compression = reply.options.compressionAlgorithm {
                switch compression {
                case .disabled:
                    break

                case .LZO:
                    if !LZOFactory.canCreate() {
                        let error = OpenVPNSessionError.serverCompression
                        pp_log(.openvpn, .fault, "Server has LZO compression enabled and this was not built into the library (framing=\(framing)): \(error)")
                        throw error
                    }

                default:
                    let error = OpenVPNSessionError.serverCompression
                    pp_log(.openvpn, .fault, "Server has non-LZO compression enabled and this is currently unsupported (framing=\(framing)): \(error)")
                    throw error
                }
            }
        } catch StandardOpenVPNParserError.continuationPushReply {
            continuatedPushReplyMessage = completeMessage.replacingOccurrences(of: "push-continuation", with: "")
            // XXX: strip "PUSH_REPLY" and "push-continuation 2"
            return
        }

        guard reply.options.ipv4 != nil || reply.options.ipv6 != nil else {
            throw OpenVPNSessionError.noRouting
        }
        guard state != .connected else {
            pp_log(.openvpn, .error, "Ignore multiple calls to complete connection")
            return
        }
        state = .connected
        try completeConnection(pushReply: reply)
    }
}

private extension Negotiator {
    func completeConnection(pushReply: PushReply) throws {
        pp_log(.openvpn, .info, "Complete connection of key \(key)")
        let history = NegotiationHistory(pushReply: pushReply)
        let dataChannel = try newDataChannel(with: history)
        self.history = history
        authenticator?.reset()
        Task {
            await options.onConnected(key, dataChannel, pushReply)
        }
    }

    func newDataChannel(with history: NegotiationHistory) throws -> DataChannel {
        guard let sessionId = channel.sessionId else {
            pp_log(.openvpn, .fault, "Setting up connection without a local sessionId")
            throw OpenVPNSessionError.assertion
        }
        guard let remoteSessionId = channel.remoteSessionId else {
            pp_log(.openvpn, .fault, "Setting up connection without a remote sessionId")
            throw OpenVPNSessionError.assertion
        }
        guard let authResponse = authenticator?.response else {
            pp_log(.openvpn, .fault, "Setting up connection without auth response")
            throw OpenVPNSessionError.assertion
        }

        pp_log(.openvpn, .notice, "Set up encryption")
//        pp_log(.openvpn, .info, "\tpreMaster: \(authenticator.preMaster.toHex(), privacy: .private)")
//        pp_log(.openvpn, .info, "\trandom1: \(authenticator.random1.toHex(), privacy: .private)")
//        pp_log(.openvpn, .info, "\trandom2: \(authenticator.random2.toHex(), privacy: .private)")
//        pp_log(.openvpn, .info, "\tserverRandom1: \(serverRandom1.toHex(), privacy: .private)")
//        pp_log(.openvpn, .info, "\tserverRandom2: \(serverRandom2.toHex(), privacy: .private)")
//        pp_log(.openvpn, .info, "\tsessionId: \(sessionId.toHex())")
//        pp_log(.openvpn, .info, "\tremoteSessionId: \(remoteSessionId.toHex())")

        let cryptoBox = cryptoFactory()
        try cryptoBox.configure(
            withCipher: history.pushReply.options.cipher ?? options.configuration.fallbackCipher,
            digest: options.configuration.fallbackDigest,
            auth: authResponse,
            sessionId: sessionId,
            remoteSessionId: remoteSessionId
        )

        let compressionFraming = history.pushReply.options.compressionFraming ?? options.configuration.fallbackCompressionFraming
        let compressionAlgorithm = history.pushReply.options.compressionAlgorithm ?? options.configuration.compressionAlgorithm ?? .disabled

        let dataPath = DataPath(
            encrypter: cryptoBox.encrypter(),
            decrypter: cryptoBox.decrypter(),
            peerId: history.pushReply.options.peerId ?? PacketPeerIdDisabled,
            compressionFraming: compressionFraming.native,
            compressionAlgorithm: compressionAlgorithm.native,
            maxPackets: options.sessionOptions.maxPackets,
            usesReplayProtection: Constants.usesReplayProtection
        )

        return DataChannel(key: key, dataPath: dataPath)
    }
}

// MARK: - Helpers

private extension Negotiator {
    enum State: Int, Comparable {
        case idle

        case tls

        case auth

        case push

        case connected

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    var elapsedSinceStart: TimeInterval {
        -startTime.timeIntervalSinceNow
    }

    var didHardResetTimeout: Bool {
        state == .idle && elapsedSinceStart > options.sessionOptions.hardResetTimeout
    }

    var didNegotiationTimeout: Bool {
        state != .connected && elapsedSinceStart > negotiationTimeout
    }
}

private extension OpenVPN.CompressionAlgorithm {
    var native: CompressionAlgorithm {
        switch self {
        case .disabled: .disabled
        case .LZO: .LZO
        case .other: .other
        @unknown default: .disabled
        }
    }
}

private extension OpenVPN.CompressionFraming {
    var native: CompressionFraming {
        switch self {
        case .disabled: .disabled
        case .compLZO: .compLZO
        case .compress: .compress
        case .compressV2: .compressV2
        @unknown default: .disabled
        }
    }
}
