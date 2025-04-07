//
//  OpenVPNSessionProtocol.swift
//  Partout
//
//  Created by Davide De Rosa on 4/12/24.
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

import Foundation
import Partout

/// Observes major events notified by a ``OpenVPNSessionProtocol``.
protocol OpenVPNSessionDelegate: AnyObject {

    /// Called after starting a session.
    ///
    /// - Parameter session: The originator.
    /// - Parameter remoteAddress: The address of the VPN server.
    /// - Parameter remoteProtocol: The endpoint protocol of the VPN server.
    /// - Parameter remoteOptions: The pulled tunnel settings.
    func sessionDidStart(_ session: OpenVPNSessionProtocol, remoteAddress: String, remoteProtocol: EndpointProtocol, remoteOptions: OpenVPN.Configuration) async

    /// Called after stopping a session.
    ///
    /// - Parameter session: The originator.
    /// - Parameter error: An optional `Error` being the reason of the stop.
    func sessionDidStop(_ session: OpenVPNSessionProtocol, withError error: Error?) async

    /// Called when the data count gets a significant update.
    ///
    /// - Parameter session: The originator.
    /// - Parameter dataCount: The data count.
    func session(_ session: OpenVPNSessionProtocol, didUpdateDataCount dataCount: DataCount) async
}

/// Provides methods to set up and maintain an OpenVPN session.
protocol OpenVPNSessionProtocol {

    /// Observe events with a ``OpenVPNSessionDelegate``.
    func setDelegate(_ delegate: OpenVPNSessionDelegate) async

    /**
     Establishes the tunnel interface for this session. The interface must be up and running for sending and receiving packets.

     - Precondition: `tunnel` is an active network interface.
     - Postcondition: The VPN data channel is open.
     - Parameter tunnel: The `TunnelInterface` on which to exchange the VPN data traffic.
     */
    func setTunnel(_ tunnel: TunnelInterface) async

    /**
     Establishes the link interface for this session. The interface must be up and running for sending and receiving packets.

     - Precondition: `link` is an active network interface.
     - Postcondition: The VPN negotiation is started.
     - Parameter link: The `LinkInterface` on which to establish the VPN session.
     */
    func setLink(_ link: LinkInterface) async throws

    /// True if a link was set via ``setLink(_:)`` and is still alive.
    func hasLink() async -> Bool

    /**
     Shuts down the session with an optional `Error` reason. Does nothing if the session is already stopped or about to stop.

     - Parameters:
       - error: An optional `Error` being the reason of the shutdown.
       - timeout: The optional timeout in seconds.
     */
    func shutdown(_ error: Error?, timeout: TimeInterval?) async
}

extension OpenVPNSessionProtocol {
    func shutdown(_ error: Error?) async {
        await shutdown(error, timeout: nil)
    }
}
