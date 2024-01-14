//
//  NEPacketTunnelProvider+Expiration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/23/23.
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

import Foundation
import NetworkExtension

extension NEPacketTunnelProvider {
    func tryStartGivenExpirationDate(withTimeIntervalKey key: String) throws {
        if let protocolConfiguration = protocolConfiguration as? NETunnelProviderProtocol,
           let expirationDateInterval = protocolConfiguration.providerConfiguration?[key] as? TimeInterval {
            let expirationDate = Date(timeIntervalSinceReferenceDate: expirationDateInterval)

            // already expired?
            let delay = Int(expirationDate.timeIntervalSinceNow)
            if delay < .zero {
                throw TunnelError.expired
            }

            // schedule connection expiration
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) { [weak self] in
                self?.cancelTunnelWithError(TunnelError.expired)
            }
        }
    }
}
