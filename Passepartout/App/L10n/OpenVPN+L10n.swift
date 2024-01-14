//
//  OpenVPN+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/26/22.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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
import PassepartoutLibrary
import TunnelKitOpenVPN

extension OpenVPN.Cipher: LocalizableEntity {
    public var localizedDescription: String {
        description
    }
}

extension OpenVPN.Digest: LocalizableEntity {
    public var localizedDescription: String {
        description
    }
}

extension OpenVPN.CompressionFraming: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .disabled:
            return L10n.Global.Strings.disabled

        case .compLZO:
            return Unlocalized.OpenVPN.compLZO

        case .compress, .compressV2:
            return Unlocalized.OpenVPN.compress
        }
    }
}

extension OpenVPN.CompressionAlgorithm: LocalizableEntity {
    public var localizedDescription: String {
        let V = L10n.Endpoint.Advanced.Openvpn.Items.self
        switch self {
        case .disabled:
            return L10n.Global.Strings.disabled

        case .LZO:
            return Unlocalized.OpenVPN.lzo

        case .other:
            return V.CompressionAlgorithm.Value.other
        }
    }
}

extension OpenVPN.XORMethod: StyledLocalizableEntity {
    public enum Style {
        case short

        case long
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .short:
            return shortDescription

        case .long:
            return longDescription
        }
    }

    private var shortDescription: String {
        switch self {
        case .xormask:
            return Unlocalized.OpenVPN.XOR.xormask.rawValue

        case .xorptrpos:
            return Unlocalized.OpenVPN.XOR.xorptrpos.rawValue

        case .reverse:
            return Unlocalized.OpenVPN.XOR.reverse.rawValue

        case .obfuscate:
            return Unlocalized.OpenVPN.XOR.obfuscate.rawValue
        }
    }

    private var longDescription: String {
        switch self {
        case .xormask(let mask):
            return "\(shortDescription) \(mask.toHex())"

        case .obfuscate(let mask):
            return "\(shortDescription) \(mask.toHex())"

        default:
            return shortDescription
        }
    }
}

extension OpenVPN.PullMask: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .routes:
            return L10n.Endpoint.Advanced.Openvpn.Items.Route.caption

        case .dns:
            return Unlocalized.Network.dns

        case .proxy:
            return L10n.Global.Strings.proxy
        }
    }
}

extension OpenVPN.ConfigurationBuilder: StyledLocalizableEntity {
    public enum Style {
        case tlsWrap

        case eku
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .tlsWrap:
            return tlsWrap.tlsWrapDescription

        case .eku:
            return checksEKU.ekuDescription
        }
    }
}

extension OpenVPN.Configuration: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case keepAlive

        case renegotiatesAfter

        case randomizeEndpoint

        case randomizeHostnames
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .keepAlive:
            return keepAliveInterval?.keepAliveDescription

        case .renegotiatesAfter:
            return renegotiatesAfter?.renegotiatesAfterDescription

        case .randomizeEndpoint:
            return randomizeEndpoint?.randomizeEndpointDescription

        case .randomizeHostnames:
            return randomizeHostnames?.randomizeHostnamesDescription
        }
    }
}

private extension Optional where Wrapped == OpenVPN.TLSWrap {
    var tlsWrapDescription: String {
        guard let strategy = self?.strategy else {
            return L10n.Global.Strings.disabled
        }
        let V = L10n.Endpoint.Advanced.Openvpn.Items.self
        switch strategy {
        case .auth:
            return V.TlsWrapping.Value.auth

        case .crypt:
            return V.TlsWrapping.Value.crypt
        }
    }
}

private extension TimeInterval {
    var keepAliveDescription: String {
        let V = L10n.Endpoint.Advanced.Openvpn.Items.self
        if self > 0 {
            return V.KeepAlive.Value.seconds(Int(self))
        } else {
            return L10n.Global.Strings.disabled
        }
    }
}

private extension Optional where Wrapped == Bool {
    var ekuDescription: String {
        let V = L10n.Global.Strings.self
        return (self ?? false) ? V.enabled : V.disabled
    }
}

private extension TimeInterval {
    var renegotiatesAfterDescription: String {
        let V = L10n.Endpoint.Advanced.Openvpn.Items.self
        if self > 0 {
            return V.RenegotiationSeconds.Value.after(TimeInterval(self).localizedDescription)
        } else {
            return L10n.Global.Strings.disabled
        }
    }
}

private extension Bool {
    var randomizeEndpointDescription: String {
        let V = L10n.Global.Strings.self
        return self ? V.enabled : V.disabled
    }

    var randomizeHostnamesDescription: String {
        let V = L10n.Global.Strings.self
        return self ? V.enabled : V.disabled
    }
}

// MARK: - Errors

extension TunnelKitOpenVPNError: LocalizedError {
    public var errorDescription: String? {
        let V = L10n.Tunnelkit.Errors.Vpn.self
        switch self {
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
            return L10n.Global.Strings.unknown
        }
    }
}

extension OpenVPN.ConfigurationError: LocalizedError {
    public var errorDescription: String? {
        let V = L10n.Tunnelkit.Errors.Openvpn.self
        switch self {
        case .encryptionPassphrase:
            pp_log.error("Could not parse configuration URL: unable to decrypt, passphrase required")
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

        case .continuationPushReply:
            assertionFailure("This is a server-side configuration parsing error")
            return L10n.Global.Strings.unknown
        }
    }
}
