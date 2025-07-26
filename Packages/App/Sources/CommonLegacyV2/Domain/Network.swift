// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

enum Network {
}

extension Network {
    enum Choice: String, Codable {
        case automatic // OpenVPN pulls from server

        case manual

        static let defaultChoice: Choice = .automatic
    }
}

protocol NetworkChoiceRepresentable {
    var choice: Network.Choice { get set }
}

protocol GatewaySettingsProviding {
    var isDefaultIPv4: Bool { get }

    var isDefaultIPv6: Bool { get }
}

protocol DNSSettingsProviding {
    var dnsProtocol: DNSProtocol? { get }

    var dnsServers: [String]? { get }

    var dnsDomain: String? { get }

    var dnsSearchDomains: [String]? { get }

    var dnsHTTPSURL: URL? { get }

    var dnsTLSServerName: String? { get }
}

protocol ProxySettingsProviding {
    var proxyServer: Endpoint? { get }

    var proxyBypassDomains: [String]? { get }

    var proxyAutoConfigurationURL: URL? { get }
}

protocol MTUSettingsProviding {
    var mtuBytes: Int { get }
}

//

extension Network {
    struct GatewaySettings: Codable, Equatable, NetworkChoiceRepresentable, GatewaySettingsProviding {
        var choice: Network.Choice

        var isDefaultIPv4 = true

        var isDefaultIPv6 = true
    }
}

extension Network {
    struct DNSSettings: Codable, Equatable, NetworkChoiceRepresentable, DNSSettingsProviding {
        enum ConfigurationType: String, Codable {
            case plain

            case https

            case tls

            case disabled
        }

        var choice: Network.Choice

        var configurationType: ConfigurationType = .plain

        var dnsProtocol: DNSProtocol? {
            DNSProtocol(rawValue: configurationType.rawValue)
        }

        var dnsServers: [String]?

        var dnsDomain: String?

        var dnsSearchDomains: [String]?

        var dnsHTTPSURL: URL?

        var dnsTLSServerName: String?
    }
}

extension Network {
    struct ProxySettings: Codable, Equatable, NetworkChoiceRepresentable, ProxySettingsProviding {
        enum ConfigurationType: String, Codable {
            case manual

            case pac

            case disabled
        }

        var choice: Network.Choice

        var configurationType: ConfigurationType = .manual

        var proxyAddress: String?

        var proxyPort: UInt16?

        var proxyBypassDomains: [String]?

        var proxyAutoConfigurationURL: URL?

        var proxyServer: Endpoint? {
            guard let address = proxyAddress, let port = proxyPort, !address.isEmpty, port > 0 else {
                return nil
            }
            return try? Endpoint(address, port)
        }
    }
}

extension Network {
    struct MTUSettings: Codable, Equatable, NetworkChoiceRepresentable, MTUSettingsProviding {
        var choice: Network.Choice

        var mtuBytes = 0
    }
}
