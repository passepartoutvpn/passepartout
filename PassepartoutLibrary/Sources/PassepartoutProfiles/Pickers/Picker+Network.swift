//
//  Picker+Network.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/26/22.
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
import TunnelKitCore
import PassepartoutCore

extension Network.DNSSettings {
    public static func availableConfigurationTypes(forVPNProtocol vpnProtocol: VPNProtocolType) -> [ConfigurationType] {
        switch vpnProtocol {
        case .openVPN:
            return [.plain, .https, .tls, .disabled]

        case .wireGuard:
            return [.plain, .https, .tls, .disabled]
        }
    }
}

extension Network.ProxySettings {
    public static let availableConfigurationTypes: [ConfigurationType] = [
        .manual,
        .pac,
        .disabled
    ]
}

extension Network.MTUSettings {
    public static let availableBytes: [Int] = [0, 1500, 1400, 1300, 1200]
}
