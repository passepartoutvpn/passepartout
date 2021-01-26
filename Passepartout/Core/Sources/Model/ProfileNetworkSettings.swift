//
//  ProfileNetworkSettings.swift
//  Passepartout
//
//  Created by Davide De Rosa on 04/28/19.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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

public enum NetworkChoice: String, Codable {
    case client
    
    case server // erase client settings
    
    case manual
    
    public static func choices(for profile: ConnectionProfile?) -> [NetworkChoice] {
        if let _ = profile as? HostConnectionProfile {
            return [.client, .server, .manual]
        }
        return [.server, .manual]
    }
}

public struct ProfileNetworkChoices: Codable {
    public static let defaultChoice: NetworkChoice = .client
    
    public var gateway: NetworkChoice

    public var dns: NetworkChoice

    public var proxy: NetworkChoice

    public var mtu: NetworkChoice?

    public init(choice: NetworkChoice) {
        gateway = choice
        dns = choice
        proxy = choice
        mtu = choice
    }

    public static func with(profile: ConnectionProfile?) -> ProfileNetworkChoices {
        if let choices = profile?.networkChoices {
            return choices
        }
        if let _ = profile as? ProviderConnectionProfile {
            return ProfileNetworkChoices(choice: .server)
        }
        return ProfileNetworkChoices(choice: .client)
    }
}

public class ProfileNetworkSettings: Codable, CustomStringConvertible {
    public static let mtuOptions: [Int] = [0, 1500, 1400, 1300, 1200]

    public var gatewayPolicies: [OpenVPN.RoutingPolicy]?

    public var dnsProtocol: DNSProtocol?
    
    public var dnsServers: [String]?
    
    public var dnsHTTPSURL: URL?
    
    public var dnsTLSServerName: String?
    
    public var dnsSearchDomains: [String]?
    
    public var proxyAddress: String?
    
    public var proxyPort: UInt16?
    
    public var proxyServer: Proxy? {
        guard let address = proxyAddress, let port = proxyPort, !address.isEmpty, port > 0 else {
            return nil
        }
        return Proxy(address, port)
    }
    
    public var proxyAutoConfigurationURL: URL?
    
    public var proxyBypassDomains: [String]?
    
    public var mtuBytes: Int?
    
    public init() {
        gatewayPolicies = [.IPv4, .IPv6]
    }
    
    public init(from configuration: OpenVPN.Configuration) {
        gatewayPolicies = configuration.routingPolicies
        dnsProtocol = configuration.dnsProtocol
        dnsServers = configuration.dnsServers
        dnsHTTPSURL = configuration.dnsHTTPSURL
        dnsTLSServerName = configuration.dnsTLSServerName
        dnsSearchDomains = configuration.searchDomains
        proxyAddress = configuration.httpProxy?.address
        proxyPort = configuration.httpProxy?.port
        proxyAutoConfigurationURL = configuration.proxyAutoConfigurationURL
        proxyBypassDomains = configuration.proxyBypassDomains
        mtuBytes = configuration.mtu
    }

    public func copy(from settings: ProfileNetworkSettings) {
        copyGateway(from: settings)
        copyDNS(from: settings)
        copyProxy(from: settings)
        copyMTU(from: settings)
    }

    public func copyGateway(from settings: ProfileNetworkSettings) {
        gatewayPolicies = settings.gatewayPolicies
    }
    
    public func copyDNS(from settings: ProfileNetworkSettings) {
        dnsProtocol = settings.dnsProtocol
        dnsServers = settings.dnsServers?.filter { !$0.isEmpty }
        dnsHTTPSURL = settings.dnsHTTPSURL
        dnsTLSServerName = settings.dnsTLSServerName
        dnsSearchDomains = settings.dnsSearchDomains
    }
    
    public func copyProxy(from settings: ProfileNetworkSettings) {
        proxyAddress = settings.proxyAddress
        proxyPort = settings.proxyPort
        proxyAutoConfigurationURL = settings.proxyAutoConfigurationURL
        proxyBypassDomains = settings.proxyBypassDomains?.filter { !$0.isEmpty }
    }
    
    public func copyMTU(from settings: ProfileNetworkSettings) {
        mtuBytes = settings.mtuBytes
    }
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        let comps: [String] = [
            "gw: \(gatewayPolicies?.description ?? "")",
            "dns: {protocol: \(dnsProtocol ?? .fallback), https: \(dnsHTTPSURL?.absoluteString ?? ""), tls: \(dnsTLSServerName?.description ?? ""), servers: \(dnsServers?.description ?? "[]"), domains: \(dnsSearchDomains?.description ?? "[]")}",
            "proxy: {address: \(proxyAddress ?? ""), port: \(proxyPort?.description ?? ""), PAC: \(proxyAutoConfigurationURL?.absoluteString ?? ""), bypass: \(proxyBypassDomains?.description ?? "[]")}",
            "mtu: {bytes: \(mtuBytes?.description ?? "default")}"
        ]
        return "{\(comps.joined(separator: ", "))}"
    }
}

extension OpenVPN.ConfigurationBuilder {
    public mutating func applyGateway(from choices: ProfileNetworkChoices, settings: ProfileNetworkSettings) {
        switch choices.gateway {
        case .client:
            break
            
        case .server:
            routingPolicies = nil
        
        case .manual:
            routingPolicies = settings.gatewayPolicies
        }
    }

    public mutating func applyDNS(from choices: ProfileNetworkChoices, settings: ProfileNetworkSettings) {
        switch choices.dns {
        case .client:
            break
            
        case .server:
            dnsProtocol = nil
            dnsServers = nil
            dnsHTTPSURL = nil
            dnsTLSServerName = nil
            searchDomains = nil

        case .manual:
            dnsProtocol = settings.dnsProtocol
            dnsServers = settings.dnsServers?.filter { !$0.isEmpty }
            dnsHTTPSURL = settings.dnsHTTPSURL
            dnsTLSServerName = settings.dnsTLSServerName
            searchDomains = settings.dnsSearchDomains
        }
    }

    public mutating func applyProxy(from choices: ProfileNetworkChoices, settings: ProfileNetworkSettings) {
        switch choices.proxy {
        case .client:
            break
            
        case .server:
            httpProxy = nil
            httpsProxy = nil
            proxyAutoConfigurationURL = nil
            proxyBypassDomains = nil
            
        case .manual:
            if let proxyServer = settings.proxyServer {
                httpProxy = proxyServer
                httpsProxy = proxyServer
                proxyBypassDomains = settings.proxyBypassDomains?.filter { !$0.isEmpty }
            } else if let pac = settings.proxyAutoConfigurationURL {
                proxyAutoConfigurationURL = pac
                proxyBypassDomains = settings.proxyBypassDomains?.filter { !$0.isEmpty }
            } else {
                httpProxy = nil
                httpsProxy = nil
                proxyAutoConfigurationURL = nil
                proxyBypassDomains = nil
            }
        }
    }
    
    public mutating func applyMTU(from choices: ProfileNetworkChoices, settings: ProfileNetworkSettings) {
        switch choices.mtu ?? ProfileNetworkChoices.defaultChoice {
        case .client:
            break
            
        case .server:
            mtu = nil
            
        case .manual:
            mtu = settings.mtuBytes
        }
    }
}

extension ConnectionProfile {
    public var clientNetworkSettings: ProfileNetworkSettings? {
        guard let hostProfile = self as? HostConnectionProfile else {
            return nil
        }
        return ProfileNetworkSettings(from: hostProfile.parameters.sessionConfiguration)
    }
}
