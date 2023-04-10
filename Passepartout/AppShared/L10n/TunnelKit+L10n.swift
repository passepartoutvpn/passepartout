//
//  TunnelKit+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/12/22.
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
import TunnelKitWireGuard
import NetworkExtension
import PassepartoutLibrary

extension VPNStatus {
    var localizedDescription: String {
        switch self {
        case .connecting:
            return L10n.Tunnelkit.Vpn.connecting

        case .connected:
            return L10n.Tunnelkit.Vpn.active

        case .disconnecting:
            return L10n.Tunnelkit.Vpn.disconnecting

        case .disconnected:
            return L10n.Tunnelkit.Vpn.inactive
        }
    }
}

extension DataCount {
    var localizedDescription: String {
        let down = received.descriptionAsDataUnit
        let up = sent.descriptionAsDataUnit
        return "↓\(down) ↑\(up)"
    }
}

extension Int {
    var localizedDescriptionAsMTU: String {
        guard self != 0 else {
            return L10n.Global.Strings.default
        }
        return description
    }
}

extension TimeInterval {
    var localizedDescriptionAsKeepAlive: String {
        let V = L10n.Endpoint.Advanced.Openvpn.Items.self
        if self > 0 {
            return V.KeepAlive.Value.seconds(Int(self))
        } else {
            return L10n.Global.Strings.disabled
        }
    }
}

extension IPv4Settings {
    var localizedAddress: String {
        "\(address)/\(addressMask)"
    }

    var localizedDefaultGateway: String {
        defaultGateway
    }
}

extension IPv6Settings {
    var localizedAddress: String {
        "\(address)/\(addressPrefixLength)"
    }

    var localizedDefaultGateway: String {
        defaultGateway
    }
}

extension IPv4Settings.Route {
    var localizedDescription: String {
        "\(destination)/\(mask) -> \(gateway ?? "*")"
    }
}

extension IPv6Settings.Route {
    var localizedDescription: String {
        "\(destination)/\(prefixLength) -> \(gateway ?? "*")"
    }
}

extension Error {
    var localizedVPNDescription: String? {
        if let ovpnError = self as? OpenVPNProviderError {
            return ovpnErrorDescription(ovpnError)
        }
        if let wgError = self as? WireGuardProviderError {
            return wgErrorDescription(wgError)
        }
        if let neError = self as? NEVPNError {
            return neErrorDescription(neError)
        }
        return localizedDescription
    }

    private func ovpnErrorDescription(_ error: OpenVPNProviderError) -> String? {
        let V = L10n.Tunnelkit.Errors.Vpn.self
        switch error {
        case .socketActivity, .timeout:
            return V.timeout

        case .dnsFailure:
            return V.dns

        case .tlsInitialization, .tlsServerVerification, .tlsHandshake:
            return V.tls

        case .authentication:
            return V.auth

        case .encryptionInitialization, .encryptionData:
            return V.encryption

        case .serverCompression, .lzo:
            return V.compression

        case .networkChanged:
            return V.network

        case .routing:
            return V.routing

        case .gatewayUnattainable:
            return V.gateway

        case .serverShutdown:
            return V.shutdown

        default:
            return nil
        }
    }

    private func wgErrorDescription(_ error: WireGuardProviderError) -> String? {
        let V = L10n.Tunnelkit.Errors.Vpn.self
        switch error {
        case .dnsResolutionFailure:
            return V.dns

        default:
            return nil
        }
    }

    private func neErrorDescription(_ error: NEVPNError) -> String? {
        error.localizedDescription.capitalized
    }
}

extension Error {
    var localizedVPNParsingDescription: String? {
        if let ovpnError = self as? OpenVPN.ConfigurationError {
            return ovpnConfigurationErrorDescription(ovpnError)
        } else if let wgError = self as? WireGuard.ConfigurationError {
            return wgConfigurationErrorDescription(wgError)
        }
        pp_log.error("Could not parse configuration URL: \(localizedDescription)")
        return L10n.Tunnelkit.Errors.parsing(localizedDescription)
    }

    private func ovpnConfigurationErrorDescription(_ error: OpenVPN.ConfigurationError) -> String {
        let V = L10n.Tunnelkit.Errors.Openvpn.self
        switch error {
        case .encryptionPassphrase:
            pp_log.error("Could not parse configuration URL: unable to decrypt, \(error.localizedDescription)")
            return V.passphraseRequired

        case .unableToDecrypt(let error):
            pp_log.error("Could not parse configuration URL: unable to decrypt, \(error.localizedDescription)")
            return V.decryption

        case .malformed(let option):
            pp_log.error("Could not parse configuration URL: malformed option, \(option)")
            return V.malformed(option)

        case .missingConfiguration(let option):
            pp_log.error("Could not parse configuration URL: missing configuration, \(option)")
            return V.requiredOption(option)

        case .unsupportedConfiguration(var option):
            if option.contains("external") {
                option.append(" (see FAQ)")
            }
            pp_log.error("Could not parse configuration URL: unsupported configuration, \(option)")
            return V.unsupportedOption(option)
        }
    }

    private func wgConfigurationErrorDescription(_ error: WireGuard.ConfigurationError) -> String {
        error.localizedDescription
    }
}
