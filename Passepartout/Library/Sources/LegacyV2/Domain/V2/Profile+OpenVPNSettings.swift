//
//  Profile+OpenVPNSettings.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/16/22.
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
import PassepartoutKit

extension ProfileV2 {
    struct OpenVPNSettings: Codable, Equatable, VPNProtocolProviding {
        var vpnProtocol: VPNProtocolType {
            .openVPN
        }

        var configuration: OpenVPN.Configuration

        var account: Account?

        var customEndpoint: Endpoint?

        init(configuration: OpenVPN.Configuration) {
            self.configuration = configuration
        }
    }

    init(_ id: UUID = UUID(), name: String, configuration: OpenVPN.Configuration) {
        let header = Header(
            uuid: id,
            name: name,
            providerName: nil
        )
        self.init(header, configuration: configuration)
    }

    init(_ header: Header, configuration: OpenVPN.Configuration) {
        self.header = header
        currentVPNProtocol = .openVPN
        host = Host()
        host?.ovpnSettings = OpenVPNSettings(configuration: configuration)
    }
}
