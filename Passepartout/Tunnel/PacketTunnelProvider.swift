//
//  PacketTunnelProvider.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/24/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import CommonLibrary
@preconcurrency import NetworkExtension
import PassepartoutKit

final class PacketTunnelProvider: NEPacketTunnelProvider, @unchecked Sendable {
    private var fwd: NEPTPForwarder?

    override func startTunnel(options: [String: NSObject]? = nil) async throws {
        CommonLibrary.configureLogging(
            to: Constants.shared.urlForTunnelLog,
            parameters: Constants.shared.log
        )
        fwd = try await NEPTPForwarder(
            provider: self,
            decoder: .shared,
            registry: .shared,
            environment: .shared
        )
        do {
            try await fwd?.startTunnel(options: options)
        } catch {
            CommonLibrary.flushLog()
            throw error
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason) async {
        await fwd?.stopTunnel(with: reason)
        fwd = nil
        CommonLibrary.flushLog()
    }

    override func cancelTunnelWithError(_ error: (any Error)?) {
        CommonLibrary.flushLog()
        super.cancelTunnelWithError(error)
    }

    override func handleAppMessage(_ messageData: Data) async -> Data? {
        await fwd?.handleAppMessage(messageData)
    }

    override func wake() {
        fwd?.wake()
    }

    override func sleep() async {
        await fwd?.sleep()
    }
}
