//
//  Profile+WireGuardSettings.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/22.
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
import PassepartoutWireGuard
import PassepartoutWireGuardGo

extension ProfileV2 {
    struct WireGuardSettings: Codable, Equatable, VPNProtocolProviding {
        struct WrappedConfiguration: Codable, Equatable {
            let configuration: WireGuard.Configuration

            init(configuration: WireGuard.Configuration) {
                self.configuration = configuration
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let wg = try container.decode(String.self)
                configuration = try StandardWireGuardParser().configuration(from: wg)
            }

            public func encode(to encoder: Encoder) throws {
                let wg = try StandardWireGuardParser().string(from: configuration)
                var container = encoder.singleValueContainer()
                try container.encode(wg)
            }
        }

        var vpnProtocol: VPNProtocolType {
            .wireGuard
        }

        var configuration: WrappedConfiguration

        init(configuration: WireGuard.Configuration) {
            self.configuration = WrappedConfiguration(configuration: configuration)
        }

    }

    init(_ id: UUID = UUID(), name: String, configuration: WireGuard.Configuration) {
        let header = Header(
            uuid: id,
            name: name,
            providerName: nil
        )
        self.init(header, configuration: configuration)
    }

    init(_ header: Header, configuration: WireGuard.Configuration) {
        self.header = header
        currentVPNProtocol = .wireGuard
        host = Host()
        host?.wgSettings = WireGuardSettings(configuration: configuration)
    }
}
