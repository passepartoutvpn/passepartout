//
//  OpenVPNSession+Negotiation.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 3/28/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import Foundation
import PassepartoutKit

extension OpenVPNSession {

    @discardableResult
    func startNegotiation(on link: LinkInterface) async throws -> Negotiator {
        pp_log(.openvpn, .info, "Start negotiation")
        let neg = newNegotiator(on: link)
        addNegotiator(neg)
        loopLink()
        try await neg.start()
        return neg
    }

    func startRenegotiation(
        after negotiator: Negotiator,
        on link: LinkInterface,
        isServerInitiated: Bool
    ) async throws -> Negotiator {
        guard await !negotiator.isRenegotiating else {
            pp_log(.openvpn, .error, "Renegotiation already in progress")
            return negotiator
        }
        if isServerInitiated {
            pp_log(.openvpn, .notice, "Renegotiation request from server")
        } else {
            pp_log(.openvpn, .notice, "Renegotiation request from client")
        }
        let neg = await negotiator.forRenegotiation(initiatedBy: isServerInitiated ? .server : .client)
        addNegotiator(neg)
        try await neg.start()
        return neg
    }
}
