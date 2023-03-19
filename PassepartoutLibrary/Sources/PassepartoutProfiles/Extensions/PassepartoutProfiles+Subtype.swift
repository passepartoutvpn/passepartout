//
//  PassepartoutProfiles+Subtype.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/20/22.
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
import PassepartoutCore
import PassepartoutProviders

extension Profile {
    public var requiresCredentials: Bool {
        if let providerName = providerName {
            return providerName.requiresCredentials(forProtocol: currentVPNProtocol)
        } else {
            return currentVPNProtocol == .openVPN && (hostOpenVPNSettings?.configuration.authUserPass ?? false)
        }
    }
}

extension Profile {
    public func providerServer(_ providerManager: ProviderManager) -> ProviderServer? {
        guard let serverId = providerServerId else {
            return nil
        }
        return providerManager.server(withId: serverId)
    }

    public func providerOpenVPNSettings(withManager providerManager: ProviderManager) throws -> Profile.OpenVPNSettings {
        guard isProvider else {
            fatalError("Not a provider")
        }

        // infer remotes from preset + server
        guard let selectedServer = providerServer(providerManager) else {
            throw PassepartoutError.missingProviderServer
        }
        let server: ProviderServer
        if providerRandomizesServer ?? false {
            let location = selectedServer.location(withVPNProtocol: currentVPNProtocol)
            let servers = providerManager.servers(forLocation: location)
            guard let randomServerId = servers.randomElement()?.id,
                  let randomServer = providerManager.server(withId: randomServerId) else {
                throw PassepartoutError.missingProviderServer
            }
            server = randomServer
        } else {
            server = selectedServer
        }
        guard let preset = providerPreset(server) else {
            throw PassepartoutError.missingProviderPreset
        }
        guard var builder = preset.openVPNConfiguration?.builder() else {
            fatalError("Preset \(preset.id) has no OpenVPN configuration")
        }
        try builder.setRemotes(from: preset, with: server, excludingHostname: !networkSettings.resolvesHostname)

        // enforce default gateway
        builder.routingPolicies = [.IPv4, .IPv6]

        // apply provider settings (username, custom endpoint)
        let cfg = builder.build()
        var settings = OpenVPNSettings(configuration: cfg)
        settings.account = providerAccount
        settings.customEndpoint = providerCustomEndpoint
        return settings
    }

    public func providerWireGuardSettings(withManager providerManager: ProviderManager) throws -> Profile.WireGuardSettings {
        guard isProvider else {
            fatalError("Not a provider")
        }
        fatalError("WireGuard not yet implemented for providers")
    }
}
