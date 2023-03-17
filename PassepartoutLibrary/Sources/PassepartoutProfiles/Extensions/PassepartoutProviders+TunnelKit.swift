//
//  PassepartoutProviders+TunnelKit.swift
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
import Combine
import TunnelKitOpenVPN
import TunnelKitWireGuard
import PassepartoutCore
import PassepartoutUtils

extension ProviderServer.Preset {
    public var openVPNConfiguration: OpenVPN.Configuration? {
        guard vpnProtocol == .openVPN else {
            return nil
        }
        guard let json = vpnConfiguration["cfg"] else {
            pp_log.error("Unable to parse preset OpenVPN configuration: no cfg")
            return nil
        }
        do {
            return try json.decode(OpenVPN.Configuration.self)
        } catch {
            pp_log.error("Unable to parse preset OpenVPN configuration: \(error)")
            return nil
        }
    }

    public var openVPNEndpoints: [EndpointProtocol] {
        guard vpnProtocol == .openVPN else {
            return []
        }
        guard let json = vpnConfiguration["endpoints"]?.arrayValue else {
            pp_log.error("Unable to parse preset OpenVPN configuration: no endpoints")
            return []
        }
        let endpoints = json
            .compactMap(\.stringValue)
            .compactMap(EndpointProtocol.init)

        guard !endpoints.isEmpty else {
            pp_log.error("Unable to parse preset OpenVPN configuration: empty/malformed endpoints")
            return []
        }
        return endpoints
    }

    public var wireGuardConfiguration: WireGuard.Configuration? {
        guard vpnProtocol == .wireGuard else {
            return nil
        }
        do {
            return try vpnConfiguration.decode(WireGuard.Configuration.self)
        } catch {
            pp_log.error("Unable to parse preset WireGuard configuration: \(error)")
            return nil
        }
    }
}

extension OpenVPN.ConfigurationBuilder {
    public mutating func setRemotes(
        from preset: ProviderServer.Preset,
        with server: ProviderServer,
        excludingHostname: Bool
    ) throws {
        var remotes: [Endpoint] = []

        let endpoints = preset.openVPNEndpoints
        if !excludingHostname, let hostname = server.hostname {
            endpoints.forEach { ep in
                remotes.append(.init(hostname, ep))
            }
        }
        endpoints.forEach { ep in
            server.ipAddresses.forEach { addr in
                remotes.append(.init(addr, ep))
            }
        }
        guard !remotes.isEmpty else {
            pp_log.warning("Excluding hostname but server has no ipAddresses either")
            throw PassepartoutError.missingProviderServer
        }

        self.remotes = remotes
    }
}
