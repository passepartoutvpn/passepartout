//
//  OpenVPNUDPLink.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 5/23/19.
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

import Combine
import Foundation
import PassepartoutKit

/// Wrapper for connecting over a UDP socket.
final class OpenVPNUDPLink {
    private let link: LinkInterface

    private let xor: XORProcessor

    /// - Parameters:
    ///   - link: The underlying socket.
    ///   - xorMethod: The optional XOR method.
    convenience init(link: LinkInterface, xorMethod: OpenVPN.XORMethod?) {
        precondition(link.linkType.plainType == .udp)
        self.init(link: link, xor: XORProcessor(method: xorMethod))
    }

    init(link: LinkInterface, xor: XORProcessor) {
        self.link = link
        self.xor = xor
    }
}

// MARK: - LinkInterface

extension OpenVPNUDPLink: LinkInterface {
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
        OpenVPNUDPLink(link: link.upgraded(), xor: xor)
    }

    func shutdown() {
        link.shutdown()
    }
}

// MARK: - IOInterface

extension OpenVPNUDPLink {
    func setReadHandler(_ handler: @escaping ([Data]?, Error?) -> Void) {
        link.setReadHandler { [weak self] packets, error in
            guard let self else {
                return
            }
            var processedPackets: [Data]?
            if let packets {
                processedPackets = xor.processPackets(packets, outbound: false)
            }
            handler(processedPackets, error)
        }
    }

    func writePackets(_ packets: [Data]) async throws {
        let processedPackets = xor.processPackets(packets, outbound: true)
        try await link.writePackets(processedPackets)
    }
}
