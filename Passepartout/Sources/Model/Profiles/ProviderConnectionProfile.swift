//
//  ProviderConnectionProfile.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/2/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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

public class ProviderConnectionProfile: ConnectionProfile, Codable, Equatable {
    public let name: Infrastructure.Name

    public var infrastructure: Infrastructure {
        return InfrastructureFactory.shared.get(name)
    }

    public var poolId: String {
        didSet {
            validateEndpoint()
        }
    }

    public var pool: Pool? {
        return infrastructure.pool(for: poolId)
    }

    public var presetId: String {
        didSet {
            validateEndpoint()
        }
    }
    
    public var preset: InfrastructurePreset? {
        return infrastructure.preset(for: presetId)
    }
    
    public var manualAddress: String?

    public var manualProtocol: EndpointProtocol?
    
    public var networkChoices: ProfileNetworkChoices?
    
    public var manualNetworkSettings: ProfileNetworkSettings?
    
    public var usesProviderEndpoint: Bool {
        return (manualAddress != nil) || (manualProtocol != nil)
    }
    
    public init(name: Infrastructure.Name) {
        self.name = name
        poolId = ""
        presetId = ""

        username = nil

        poolId = infrastructure.defaultPool()?.id ?? infrastructure.defaults.pool
        presetId = infrastructure.defaults.preset
    }
    
    public func setSupportedPreset() {
        guard let pool = pool else {
            return
        }
        let supported = pool.supportedPresetIds(in: infrastructure)
        if let current = preset?.id, !supported.contains(current), let fallback = supported.first {
            presetId = fallback
        }
    }
    
    private func validateEndpoint() {
        guard let pool = pool, let preset = preset else {
            manualAddress = nil
            manualProtocol = nil
            return
        }
        if let address = manualAddress, !pool.hasAddress(address) {
            manualAddress = nil
        }
        if let proto = manualProtocol, !preset.hasProtocol(proto) {
            manualProtocol = nil
        }
    }
    
    // MARK: ConnectionProfile
    
    public let context: Context = .provider

    public var id: String {
        return name.rawValue
    }
    
    public var username: String?
    
    public var requiresCredentials: Bool {
        return true
    }
    
    public func generate(from configuration: OpenVPNTunnelProvider.Configuration, preferences: Preferences) throws -> OpenVPNTunnelProvider.Configuration {
        guard let pool = pool else {
            preconditionFailure("Nil pool?")
        }
        guard let preset = preset else {
            preconditionFailure("Nil preset?")
        }

//        assert(!pool.numericAddresses.isEmpty)

        // XXX: copy paste, error prone
        var builder = preset.configuration.builder()
        builder.mtu = configuration.mtu
        builder.shouldDebug = configuration.shouldDebug
        builder.debugLogFormat = configuration.debugLogFormat
        builder.masksPrivateData = configuration.masksPrivateData
        
        do {
            try preset.injectExternalConfiguration(&builder, with: name, pool: pool)
        } catch {
            throw ApplicationError.externalResources
        }

        if let address = manualAddress {
            builder.prefersResolvedAddresses = true
            builder.resolvedAddresses = [address]
        } else if builder.sessionConfiguration.hostname == nil {
            builder.prefersResolvedAddresses = true
            builder.resolvedAddresses = pool.addresses()
        } else {
            builder.prefersResolvedAddresses = !preferences.resolvesHostname
            builder.resolvedAddresses = pool.addresses()
        }
        
        var sessionBuilder = builder.sessionConfiguration.builder()
        if let proto = manualProtocol {
            sessionBuilder.endpointProtocols = [proto]
        } else {
            
            // restrict "Any" protocol to UDP, unless there are no UDP endpoints
            let allEndpoints = builder.sessionConfiguration.endpointProtocols
            var endpoints = allEndpoints?.filter { $0.socketType == .udp }
            if endpoints?.isEmpty ?? true {
                endpoints = allEndpoints
            }
            
            sessionBuilder.endpointProtocols = endpoints
//            sessionBuilder.endpointProtocols = [
//                EndpointProtocol(.udp, 8080),
//                EndpointProtocol(.tcp, 443)
//            ]
        }
        builder.sessionConfiguration = sessionBuilder.build()
        
        return builder.build()
    }

    public func with(newId: String) -> ConnectionProfile {
        fatalError("Cannot rename a ProviderConnectionProfile")
    }
}

public extension ProviderConnectionProfile {
    static func ==(lhs: ProviderConnectionProfile, rhs: ProviderConnectionProfile) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension ProviderConnectionProfile {
    var mainAddress: String? {
        guard let pool = pool else {
            assertionFailure("Getting provider main address but no pool set")
            return nil
        }
        return pool.hostname
    }
    
    var addresses: [String] {
        var addrs = pool?.addresses() ?? []
        if let pool = pool, pool.hostname == nil, !(pool.isResolved ?? false), let externalHostname = try? preset?.externalConfiguration(forKey: .hostname, infrastructureName: infrastructure.name, pool: pool) as? String {
            addrs.insert(externalHostname, at: 0)
        }
        return addrs
    }
    
    var protocols: [EndpointProtocol] {
        return preset?.configuration.sessionConfiguration.endpointProtocols ?? []
    }
    
    var canCustomizeEndpoint: Bool {
        return true
    }
    
    var customAddress: String? {
        return manualAddress
    }

    var customProtocol: EndpointProtocol? {
        return manualProtocol
    }
}
