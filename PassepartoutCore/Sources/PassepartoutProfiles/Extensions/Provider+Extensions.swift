//
//  Provider+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import PassepartoutProviders
import PassepartoutUtils

extension Profile {
    public init(_ providerMetadata: ProviderMetadata, server: ProviderServer) {
        guard let vpnProtocol = server.presets?.first?.vpnProtocol else {
            fatalError("Server has no presets")
        }
        
        var provider = Provider(providerMetadata.name)
        var settings = Provider.Settings()
        settings.serverId = server.id
        settings.presetId = server.presetIds.first
        provider.vpnSettings[vpnProtocol] = settings

        self.init(name: providerMetadata.fullName, provider: provider)
    }

    @MainActor
    public func providerServer(_ providerManager: ProviderManager) -> ProviderServer? {
        guard let serverId = provider?.vpnSettings[currentVPNProtocol]?.serverId else {
            return nil
        }
        return providerManager.server(withId: serverId)
    }

    public func providerServerId() -> String? {
        return provider?.vpnSettings[currentVPNProtocol]?.serverId
    }

    public mutating func setProviderServer(_ server: ProviderServer) {
        let oldServerId = provider?.vpnSettings[currentVPNProtocol]?.serverId
        provider?.vpnSettings[currentVPNProtocol]?.serverId = server.id
        provider?.vpnSettings[currentVPNProtocol]?.customEndpoint = nil

        // if server changed, pick first preset
        if server.id != oldServerId {
            provider?.vpnSettings[currentVPNProtocol]?.presetId = server.presetIds.first
        }
    }

    public func providerPreset(_ server: ProviderServer) -> ProviderServer.Preset? {
        guard let presetId = provider?.vpnSettings[currentVPNProtocol]?.presetId else {
            return nil
        }
        return server.preset(withId: presetId)
    }

    public mutating func setProviderPreset(_ preset: ProviderServer.Preset) {
        provider?.vpnSettings[currentVPNProtocol]?.presetId = preset.id
    }
    
    public func providerFavoriteLocationIds() -> Set<String>? {
        return provider?.vpnSettings[currentVPNProtocol]?.favoriteLocationIds
    }
    
    public mutating func setProviderFavoriteLocationIds(_ ids: Set<String>?) {
        provider?.vpnSettings[currentVPNProtocol]?.favoriteLocationIds = ids
    }

    public func providerCustomEndpoint() -> Endpoint? {
        return provider?.vpnSettings[currentVPNProtocol]?.customEndpoint
    }

    public mutating func setProviderCustomEndpoint(_ endpoint: Endpoint?) {
        provider?.vpnSettings[currentVPNProtocol]?.customEndpoint = endpoint
    }
    
    public func providerAccount() -> Profile.Account? {
        return provider?.vpnSettings[currentVPNProtocol]?.account
    }
    
    public mutating func setProviderAccount(_ account: Profile.Account?) {
        provider?.vpnSettings[currentVPNProtocol]?.account = account
    }
}

extension Profile {

    @MainActor
    public func providerOpenVPNSettings(withManager providerManager: ProviderManager) throws -> Profile.OpenVPNSettings {
        guard let _ = provider else {
            fatalError("Not a provider")
        }

        // infer remotes from preset + server
        guard let server = providerServer(providerManager) else {
            throw PassepartoutError.missingProviderServer
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
        return OpenVPNSettings(
            configuration: cfg,
            account: providerAccount(),
            customEndpoint: providerCustomEndpoint()
        )
    }

    public func providerWireGuardSettings(withManager providerManager: ProviderManager) throws -> Profile.WireGuardSettings {
        guard let _ = provider else {
            fatalError("Not a provider")
        }
        fatalError("WireGuard not yet implemented for providers")
    }
}

extension Profile.Provider: ProfileSubtype {
    public var vpnProtocols: [VPNProtocolType] {
        return vpnSettings.keys.sorted()
    }
    
    public func requiresCredentials(forProtocol vpnProtocol: VPNProtocolType) -> Bool {
        return name.requiresCredentials(forProtocol: vpnProtocol)
    }
}
