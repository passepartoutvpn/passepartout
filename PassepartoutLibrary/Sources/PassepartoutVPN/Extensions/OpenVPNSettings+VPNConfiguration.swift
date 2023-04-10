//
//  OpenVPNSettings+VPNConfiguration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/7/22.
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
import TunnelKitManager
import TunnelKitOpenVPN
import PassepartoutCore
import PassepartoutUtils

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
        if parameters.withNetworkSettings {
            customBuilder.applyGateway(from: parameters.networkSettings.gateway)
            customBuilder.applyDNS(from: parameters.networkSettings.dns)
            customBuilder.applyProxy(from: parameters.networkSettings.proxy)
            customBuilder.applyMTU(from: parameters.networkSettings.mtu)
        }

        let customConfiguration = customBuilder.build()

        var cfg = OpenVPN.ProviderConfiguration(
            parameters.title,
            appGroup: parameters.appGroup,
            configuration: customConfiguration
        )
        cfg.username = parameters.username
        cfg.shouldDebug = true
        if let filename = parameters.preferences.tunnelLogPath {
            cfg.debugLogPath = vpnPath(with: filename)
        }
        cfg.debugLogFormat = parameters.preferences.tunnelLogFormat
        cfg.masksPrivateData = parameters.preferences.masksPrivateData

        var extra = NetworkExtensionExtra()
        extra.passwordReference = parameters.passwordReference
        extra.onDemandRules = parameters.onDemandRules
        extra.disconnectsOnSleep = !parameters.networkSettings.keepsAliveOnSleep
        extra.killSwitch = true

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
            appendNoPullMask(.routes)
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
            appendNoPullMask(.dns)
            let isDNSEnabled = settings.configurationType != .disabled
            self.isDNSEnabled = isDNSEnabled

            switch settings.configurationType {
            case .plain:
                dnsProtocol = .plain

            case .https:
                dnsProtocol = .https
                dnsHTTPSURL = settings.dnsHTTPSURL

            case .tls:
                dnsProtocol = .tls
                dnsTLSServerName = settings.dnsTLSServerName

            case .disabled:
                break
            }

            if isDNSEnabled {
                dnsServers = settings.dnsServers?.filter { !$0.isEmpty }
                dnsDomain = settings.dnsDomain
                searchDomains = settings.dnsSearchDomains
            }
        }
    }

    mutating func applyProxy(from settings: Network.ProxySettings) {
        switch settings.choice {
        case .automatic:
            break

        case .manual:
            appendNoPullMask(.proxy)
            isProxyEnabled = settings.configurationType != .disabled

            switch settings.configurationType {
            case .manual:
                httpProxy = settings.proxyServer
                httpsProxy = settings.proxyServer
                proxyBypassDomains = settings.proxyBypassDomains?.filter { !$0.isEmpty }
                proxyAutoConfigurationURL = nil

            case .pac:
                httpProxy = nil
                httpsProxy = nil
                proxyBypassDomains = nil
                proxyAutoConfigurationURL = settings.proxyAutoConfigurationURL

            case .disabled:
                break
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

    private mutating func appendNoPullMask(_ mask: OpenVPN.PullMask) {
        if noPullMask == nil {
            noPullMask = []
        }
        noPullMask?.append(mask)
    }
}
