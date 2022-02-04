//
//  ProviderConnectionProfile.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/2/18.
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
import TunnelKit
import TunnelKitOpenVPN
import PassepartoutConstants

public class ProviderConnectionProfile: ConnectionProfile, Codable, Equatable {

    // XXX: drop after @transient serviceDelegate
    public enum CodingKeys: CodingKey {
        case name
        
        case poolId
        
        case presetId
        
        case customAddress
        
        case customProtocol

        case favoriteGroupIds

        case username
        
        case trustedNetworks

        case networkChoices
        
        case manualNetworkSettings
    }
    
    public let name: InfrastructureName

    public var infrastructure: Infrastructure {
        guard let infra = InfrastructureFactory.shared.infrastructure(forName: name) else {
            fatalError("No infrastructure found for '\(name)'")
        }
        return infra
    }

    public var poolId: String {
        didSet {
            validateEndpoint()
            serviceDelegate?.connectionService(didUpdate: self)
        }
    }

    public var pool: Pool? {
        return infrastructure.pool(for: poolId)
    }

    public var presetId: String {
        didSet {
            validateEndpoint()
            serviceDelegate?.connectionService(didUpdate: self)
        }
    }
    
    public var preset: InfrastructurePreset? {
        return infrastructure.preset(for: presetId)
    }
    
    public var customAddress: String?

    public var customProtocol: EndpointProtocol?
    
    public var favoriteGroupIds: [String]?

    public init(name: InfrastructureName) {
        self.name = name
        poolId = ""
        presetId = ""

        username = nil

        poolId = infrastructure.defaultPool()?.id ?? infrastructure.defaults.pool
        presetId = infrastructure.defaults.preset

        trustedNetworks = TrustedNetworks()
        favoriteGroupIds = []
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
            customAddress = nil
            customProtocol = nil
            return
        }
        if let address = customAddress, !pool.hasAddress(address) {
            customAddress = nil
        }
        if let proto = customProtocol, !preset.hasProtocol(proto) {
            customProtocol = nil
        }
    }
    
    // MARK: ConnectionProfile
    
    public var context: Context {
        return .provider
    }

    public var id: String {
        return name
    }
    
    public var username: String?
    
    public var requiresCredentials: Bool {
        return true
    }
    
    public var trustedNetworks: TrustedNetworks!

    public var networkChoices: ProfileNetworkChoices?
    
    public var manualNetworkSettings: ProfileNetworkSettings?
    
    public weak var serviceDelegate: ConnectionServiceDelegate?

    public func generate(from configuration: OpenVPNProvider.Configuration, preferences: Preferences) throws -> OpenVPNProvider.Configuration {
        guard let pool = pool else {
            preconditionFailure("Nil pool?")
        }
        guard let preset = preset else {
            preconditionFailure("Nil preset?")
        }

//        assert(!pool.numericAddresses.isEmpty)

        // XXX: copy paste, error prone
        var builder = preset.configuration.builder()
        builder.shouldDebug = configuration.shouldDebug
        builder.debugLogFormat = configuration.debugLogFormat
        builder.masksPrivateData = configuration.masksPrivateData
        
        do {
            try preset.injectExternalConfiguration(&builder, with: name, pool: pool)
        } catch {
            throw ApplicationError.externalResources
        }

        if let address = customAddress {
            builder.prefersResolvedAddresses = true
            builder.resolvedAddresses = [address]
        } else if builder.sessionConfiguration.hostname == nil || (pool.isResolved ?? false) {
            builder.prefersResolvedAddresses = true
            builder.resolvedAddresses = pool.addresses()
        } else {
            builder.prefersResolvedAddresses = !preferences.resolvesHostname
            builder.resolvedAddresses = pool.addresses()
        }
        
        var sessionBuilder = builder.sessionConfiguration.builder()
        if let proto = customProtocol {
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
        sessionBuilder.routingPolicies = [.IPv4, .IPv6]
        if sessionBuilder.mtu == nil {
            sessionBuilder.mtu = configuration.sessionConfiguration.mtu
        }
        builder.sessionConfiguration = sessionBuilder.build()
        
        return builder.build()
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
}
