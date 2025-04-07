//
//  OpenVPNSession+Negotiation.swift
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

import Foundation
import Partout

extension OpenVPNSession {

    @discardableResult
    func startNegotiation(on link: LinkInterface) throws -> Negotiator {
        pp_log(.openvpn, .info, "Start negotiation")
        let neg = newNegotiator(on: link)
        addNegotiator(neg)
        loopLink()
        try neg.start()
        return neg
    }

    func startRenegotiation(
        after negotiator: Negotiator,
        on link: LinkInterface,
        isServerInitiated: Bool
    ) throws -> Negotiator {
        guard !negotiator.isRenegotiating else {
            pp_log(.openvpn, .error, "Renegotiation already in progress")
            return negotiator
        }
        if isServerInitiated {
            pp_log(.openvpn, .notice, "Renegotiation request from server")
        } else {
            pp_log(.openvpn, .notice, "Renegotiation request from client")
        }
        let neg = negotiator.forRenegotiation(initiatedBy: isServerInitiated ? .server : .client)
        addNegotiator(neg)
        try neg.start()
        return neg
    }
}
