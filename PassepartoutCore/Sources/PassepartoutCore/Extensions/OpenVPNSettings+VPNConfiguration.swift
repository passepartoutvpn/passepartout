//
//  OpenVPNSettings+VPNConfiguration.swift
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
import TunnelKitOpenVPN

extension Profile.OpenVPNSettings: VPNConfigurationProviding {
    func vpnConfiguration(_ parameters: VPNConfigurationParameters) throws -> VPNConfiguration {
        var customBuilder = configuration.builder()

        // tolerate widest range of certificates
        customBuilder.tlsSecurityLevel = 0

        // custom endpoint
        if let endpoint = customEndpoint {
            customBuilder.remotes = [endpoint]
        }

        // network settings
        customBuilder.applyGateway(from: parameters.networkSettings.gateway)
        customBuilder.applyDNS(from: parameters.networkSettings.dns)
        customBuilder.applyProxy(from: parameters.networkSettings.proxy)
        customBuilder.applyMTU(from: parameters.networkSettings.mtu)

        let customConfiguration = customBuilder.build()

        var cfg = OpenVPN.ProviderConfiguration(
            parameters.title,
            appGroup: parameters.appGroup,
            configuration: customConfiguration
        )
        cfg.shouldDebug = true
        cfg.debugLogFormat = parameters.preferences.tunnelLogFormat
        cfg.masksPrivateData = parameters.preferences.masksPrivateData
        cfg.username = parameters.username
        
        var extra = NetworkExtensionExtra()
        extra.passwordReference = parameters.passwordReference
        extra.onDemandRules = parameters.onDemandRules
        extra.disconnectsOnSleep = !parameters.networkSettings.keepsAliveOnSleep

        pp_log.verbose("Configuration:")
        pp_log.verbose(cfg)
        pp_log.verbose(extra)

        return (cfg, extra)
    }
}

extension OpenVPN.ConfigurationBuilder {
    mutating func applyGateway(from settings: Network.GatewaySettings) {
        switch settings.choice {
        case .automatic:
            break
        
        case .manual:
            var policies: [OpenVPN.RoutingPolicy] = []
            if settings.isDefaultIPv4 {
                policies.append(.IPv4)
            }
            if settings.isDefaultIPv6 {
                policies.append(.IPv6)
            }
            routingPolicies = policies
        }
    }

    mutating func applyDNS(from settings: Network.DNSSettings) {
        switch settings.choice {
        case .automatic:
            break

        case .manual:
            isDNSEnabled = settings.isDNSEnabled

            if settings.isDNSEnabled {
                dnsProtocol = settings.dnsProtocol
                dnsServers = settings.dnsServers.filter { !$0.isEmpty }
                dnsHTTPSURL = settings.dnsHTTPSURL
                dnsTLSServerName = settings.dnsTLSServerName
                searchDomains = settings.dnsSearchDomains
            }
        }
    }

    mutating func applyProxy(from settings: Network.ProxySettings) {
        switch settings.choice {
        case .automatic:
            break

        case .manual:
            isProxyEnabled = settings.isProxyEnabled

            if settings.isProxyEnabled {
                if let proxyServer = settings.proxyServer {
                    httpProxy = proxyServer
                    httpsProxy = proxyServer
                } else if let pac = settings.proxyAutoConfigurationURL {
                    proxyAutoConfigurationURL = pac
                }
                proxyBypassDomains = settings.proxyBypassDomains.filter { !$0.isEmpty }
            }
        }
    }
    
    mutating func applyMTU(from settings: Network.MTUSettings) {
        switch settings.choice {
        case .automatic:
            break

        case .manual:
            mtu = settings.mtuBytes
        }
    }
}
