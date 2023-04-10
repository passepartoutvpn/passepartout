//
//  Network.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/15/22.
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
import TunnelKitCore

public enum Network {
}

extension Network {
    public enum Choice: String, Codable {
        case automatic // OpenVPN pulls from server

        case manual

        public static let defaultChoice: Choice = .automatic
    }
}

public protocol NetworkChoiceRepresentable {
    var choice: Network.Choice { get set }
}

public protocol GatewaySettingsProviding {
    var isDefaultIPv4: Bool { get }

    var isDefaultIPv6: Bool { get }
}

public protocol DNSSettingsProviding {
    var dnsProtocol: DNSProtocol? { get }

    var dnsServers: [String]? { get }

    var dnsDomain: String? { get }

    var dnsSearchDomains: [String]? { get }

    var dnsHTTPSURL: URL? { get }

    var dnsTLSServerName: String? { get }
}

public protocol ProxySettingsProviding {
    var proxyServer: Proxy? { get }

    var proxyBypassDomains: [String]? { get }

    var proxyAutoConfigurationURL: URL? { get }
}

public protocol MTUSettingsProviding {
    var mtuBytes: Int { get }
}

//

extension Network {
    public struct GatewaySettings: Codable, Equatable, NetworkChoiceRepresentable, GatewaySettingsProviding {
        public var choice: Network.Choice

        public var isDefaultIPv4 = true

        public var isDefaultIPv6 = true
    }
}

extension Network {
    public struct DNSSettings: Codable, Equatable, NetworkChoiceRepresentable, DNSSettingsProviding {
        public enum ConfigurationType: String, Codable {
            case plain

            case https

            case tls

            case disabled
        }

        public var choice: Network.Choice

        public var configurationType: ConfigurationType = .plain

        public var dnsProtocol: DNSProtocol? {
            DNSProtocol(rawValue: configurationType.rawValue)
        }

        public var dnsServers: [String]?

        public var dnsDomain: String?

        public var dnsSearchDomains: [String]?

        public var dnsHTTPSURL: URL?

        public var dnsTLSServerName: String?
    }
}

extension Network {
    public struct ProxySettings: Codable, Equatable, NetworkChoiceRepresentable, ProxySettingsProviding {
        public enum ConfigurationType: String, Codable {
            case manual

            case pac

            case disabled
        }

        public var choice: Network.Choice

        public var configurationType: ConfigurationType = .manual

        public var proxyAddress: String?

        public var proxyPort: UInt16?

        public var proxyBypassDomains: [String]?

        public var proxyAutoConfigurationURL: URL?

        public var proxyServer: Proxy? {
            guard let address = proxyAddress, let port = proxyPort, !address.isEmpty, port > 0 else {
                return nil
            }
            return Proxy(address, port)
        }
    }
}

extension Network {
    public struct MTUSettings: Codable, Equatable, NetworkChoiceRepresentable, MTUSettingsProviding {
        public var choice: Network.Choice

        public var mtuBytes = 0
    }
}
