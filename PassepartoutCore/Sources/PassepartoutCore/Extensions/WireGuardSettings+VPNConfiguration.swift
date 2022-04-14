//
//  WireGuardSettings+VPNConfiguration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/7/22.
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
import TunnelKitWireGuard

extension Profile.WireGuardSettings: VPNConfigurationProviding {

    @MainActor
    func vpnConfiguration(_ parameters: VPNConfigurationParameters) throws -> VPNConfiguration {
        var customBuilder = configuration.builder()

        // network settings
        if parameters.withNetworkSettings {
            customBuilder.applyGateway(from: parameters.networkSettings.gateway)
            customBuilder.applyDNS(from: parameters.networkSettings.dns)
            customBuilder.applyMTU(from: parameters.networkSettings.mtu)
        }

        let customConfiguration = customBuilder.build()

        var cfg = WireGuard.ProviderConfiguration(
            parameters.title,
            appGroup: parameters.appGroup,
            configuration: customConfiguration
        )
        cfg.shouldDebug = true
        cfg.debugLogFormat = parameters.preferences.tunnelLogFormat

        var extra = NetworkExtensionExtra()
        extra.onDemandRules = parameters.onDemandRules
        extra.disconnectsOnSleep = !parameters.networkSettings.keepsAliveOnSleep

        pp_log.verbose("Configuration:")
        pp_log.verbose(cfg)
        pp_log.verbose(extra)

        return (cfg, extra)
    }
}

extension WireGuard.ConfigurationBuilder {
    mutating func applyGateway(from settings: Network.GatewaySettings) {
        switch settings.choice {
        case .automatic:
            break
        
        case .manual:
            for i in 0..<peersCount {
                if settings.isDefaultIPv4 {
                    addDefaultGatewayIPv4(toPeer: i)
                } else {
                    removeDefaultGatewayIPv4(fromPeer: i)
                }
                if settings.isDefaultIPv6 {
                    addDefaultGatewayIPv6(toPeer: i)
                } else {
                    removeDefaultGatewayIPv6(fromPeer: i)
                }
            }
        }
    }

    mutating func applyDNS(from settings: Network.DNSSettings) {
        switch settings.choice {
        case .automatic:
            break

        case .manual:
            switch settings.configurationType {
            case .plain:
                dnsServers = settings.dnsServers ?? []
                dnsSearchDomains = settings.dnsSearchDomains?.filter { !$0.isEmpty } ?? []

            case .disabled:
                dnsServers = []
                dnsSearchDomains = []

            default:
                fatalError("Invalid DNS configuration for WireGuard: \(settings.configurationType)")
            }
        }
    }

    mutating func applyMTU(from settings: Network.MTUSettings) {
        switch settings.choice {
        case .automatic:
            break

        case .manual:
            mtu = UInt16(settings.mtuBytes)
        }
    }
}
