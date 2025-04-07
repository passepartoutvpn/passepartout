//
//  OpenVPNTCPLink.swift
//  Partout
//
//  Created by Davide De Rosa on 5/23/19.
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

import Combine
internal import CPartoutCryptoOpenSSL
internal import CPartoutOpenVPNOpenSSL
import Foundation
import Partout

/// Wrapper for connecting over a TCP socket.
final class OpenVPNTCPLink {
    private let link: LinkInterface

    private let xorMethod: OpenVPN.XORMethod?

    private let xorMask: ZeroingData?

    // WARNING: not thread-safe, only use in setReadHandler()
    private var buffer: Data

    /// - Parameters:
    ///   - link: The underlying socket.
    ///   - xorMethod: The optional XOR method.
    init(link: LinkInterface, xorMethod: OpenVPN.XORMethod?) {
        precondition(link.linkType.plainType == .tcp)

        self.link = link
        self.xorMethod = xorMethod
        xorMask = xorMethod?.mask?.zData
        buffer = Data(capacity: 1024 * 1024)
    }
}

// MARK: - LinkInterface

extension OpenVPNTCPLink: LinkInterface {
    var linkType: IPSocketType {
        link.linkType
    }

    var remoteAddress: String {
        link.remoteAddress
    }

    var remoteProtocol: EndpointProtocol {
        link.remoteProtocol
    }

    var hasBetterPath: AnyPublisher<Void, Never> {
        link.hasBetterPath
    }

    func upgraded() -> LinkInterface {
        OpenVPNTCPLink(link: link.upgraded(), xorMethod: xorMethod)
    }

    func shutdown() {
        link.shutdown()
    }
}

// MARK: - IOInterface

extension OpenVPNTCPLink {
    func setReadHandler(_ handler: @escaping ([Data]?, Error?) -> Void) {
        link.setReadHandler { [weak self] packets, error in
            guard let self else {
                return
            }
            guard error == nil, let packets else {
                handler(nil, error)
                return
            }

            buffer += packets.joined()
            var until = 0
            let processedPackets = PacketStream.packets(
                fromInboundStream: buffer,
                until: &until,
                xorMethod: self.xorMethod?.native ?? .none,
                xorMask: self.xorMask
            )
            buffer = buffer.subdata(in: until..<buffer.count)

            handler(processedPackets, error)
        }
    }

    func writePackets(_ packets: [Data]) async throws {
        let stream = PacketStream.outboundStream(
            fromPackets: packets,
            xorMethod: xorMethod?.native ?? .none,
            xorMask: xorMask
        )
        try await link.writePackets([stream])
    }
}

private extension OpenVPN.XORMethod {
    var native: XORMethodNative {
        switch self {
        case .xormask:
            return .mask

        case .xorptrpos:
            return .ptrPos

        case .reverse:
            return .reverse

        case .obfuscate:
            return .obfuscate

        @unknown default:
            return .mask
        }
    }
}
