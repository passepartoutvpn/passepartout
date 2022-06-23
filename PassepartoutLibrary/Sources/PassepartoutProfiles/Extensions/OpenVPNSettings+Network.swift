//
//  OpenVPNSettings+Network.swift
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
import TunnelKitOpenVPN
import PassepartoutCore

extension Profile.OpenVPNSettings: GatewaySettingsProviding {

    // route-gateway
    public var isDefaultIPv4: Bool {
        return configuration.routingPolicies?.contains(.IPv4) ?? false
    }

    // ifconfig-ipv6
    public var isDefaultIPv6: Bool {
        return configuration.routingPolicies?.contains(.IPv6) ?? false
    }
}

extension Profile.OpenVPNSettings: DNSSettingsProviding {

    // not a dhcp-option
    public var dnsProtocol: DNSProtocol? {
        return (configuration.isDNSEnabled ?? true) ? .plain : nil
    }
    
    // dhcp-option DNS
    public var dnsServers: [String]? {
        return configuration.dnsServers
    }
    
    // dhcp-option DOMAIN/DOMAIN-SEARCH
    public var dnsSearchDomains: [String]? {
        return configuration.searchDomains
    }
    
    // not a dhcp-option
    public var dnsHTTPSURL: URL? {
        return nil
    }
    
    // not a dhcp-option
    public var dnsTLSServerName: String? {
        return nil
    }
}

extension Profile.OpenVPNSettings: ProxySettingsProviding {

    // dhcp-option PROXY_HTTP[S]
    public var proxyServer: Proxy? {
        return configuration.httpsProxy ?? configuration.httpProxy
    }
    
    // dhcp-option PROXY_BYPASS
    public var proxyBypassDomains: [String]? {
        return configuration.proxyBypassDomains
    }

    // dhcp-option PROXY_AUTO_CONFIG_URL
    public var proxyAutoConfigurationURL: URL? {
        return configuration.proxyAutoConfigurationURL
    }
}

extension Profile.OpenVPNSettings: MTUSettingsProviding {
    public var mtuBytes: Int {

        // tun-mtu
        return configuration.mtu ?? 0
    }
}
