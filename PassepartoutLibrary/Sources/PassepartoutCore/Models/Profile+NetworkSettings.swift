//
//  Profile+NetworkSettings.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/15/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import TunnelKit

extension Profile {
    public struct NetworkSettings: Codable, Equatable {
        public var gateway: Network.GatewaySettings

        public var dns: Network.DNSSettings

        public var proxy: Network.ProxySettings

        public var mtu: Network.MTUSettings

        public var resolvesHostname = true

        public var keepsAliveOnSleep = true

        public init(choice: Network.Choice) {
            gateway = Network.GatewaySettings(choice: choice)
            dns = Network.DNSSettings(choice: choice)
            proxy = Network.ProxySettings(choice: choice)
            mtu = Network.MTUSettings(choice: choice)
        }

        public init() {
            self.init(choice: .defaultChoice)
        }
    }
}
