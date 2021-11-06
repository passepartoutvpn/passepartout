//
//  Descriptible.swift
//  Passepartout
//
//  Created by Davide De Rosa on 1/12/21.
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
import PassepartoutCore

public protocol UIDescriptible {
    var uiDescription: String { get }
}

extension OpenVPN.Cipher: UIDescriptible {
    public var uiDescription: String {
        return description
    }
}

extension OpenVPN.Digest: UIDescriptible {
    public var uiDescription: String {
        return description
    }
}

extension OpenVPN.CompressionFraming: UIDescriptible {
    public var uiDescription: String {
        let V = L10n.Configuration.Cells.self
        switch self {
        case .disabled:
            return L10n.Global.Values.disabled
            
        case .compLZO:
            return V.CompressionFraming.Value.lzo
            
        case .compress, .compressV2:
            return V.CompressionFraming.Value.compress
        }
    }
}

extension OpenVPN.CompressionAlgorithm: UIDescriptible {
    public var uiDescription: String {
        let V = L10n.Configuration.Cells.self
        switch self {
        case .disabled:
            return L10n.Global.Values.disabled
            
        case .LZO:
            return V.CompressionAlgorithm.Value.lzo
            
        case .other:
            return V.CompressionAlgorithm.Value.other
        }
    }
}

extension OpenVPN.ConfigurationBuilder {
    public var uiDescriptionForTLSWrap: String {
        let V = L10n.Configuration.Cells.self
        if let strategy = tlsWrap?.strategy {
            switch strategy {
            case .auth:
                return V.TlsWrapping.Value.auth

            case .crypt:
                return V.TlsWrapping.Value.crypt
            }
        } else {
            return L10n.Global.Values.disabled
        }
    }

    public var uiDescriptionForKeepAlive: String {
        let V = L10n.Configuration.Cells.self
        if let keepAlive = keepAliveInterval, keepAlive > 0 {
            return V.KeepAlive.Value.seconds(Int(keepAlive))
        } else {
            return L10n.Global.Values.disabled
        }
    }

    public var uiDescriptionForClientCertificate: String {
        let V = L10n.Configuration.Cells.Client.Value.self
        return (clientCertificate != nil) ? V.enabled : V.disabled
    }

    public var uiDescriptionForEKU: String {
        let V = L10n.Global.Values.self
        return (checksEKU ?? false) ? V.enabled : V.disabled
    }

    public var uiDescriptionForRenegotiatesAfter: String {
        let V = L10n.Configuration.Cells.self
        if let reneg = renegotiatesAfter, reneg > 0 {
            return V.RenegotiationSeconds.Value.after(TimeInterval(reneg).localized)
        } else {
            return L10n.Global.Values.disabled
        }
    }

    public var uiDescriptionForRandomizeEndpoint: String {
        let V = L10n.Global.Values.self
        return (randomizeEndpoint ?? false) ? V.enabled : V.disabled
    }

    public var uiDescriptionForXOR: String {
        let V = L10n.Global.Values.self
        guard let mask = xorMask, mask != 0 else {
            return V.disabled
        }

        return String(format: "0x%02x", UInt8(mask))
    }
}

extension NetworkChoice: CustomStringConvertible {
    public var description: String {
        switch self {
        case .client:
            return L10n.NetworkChoice.client
            
        case .server:
            return L10n.NetworkChoice.server
            
        case .manual:
            return L10n.Global.Values.manual
        }
    }
}

extension DNSProtocol: CustomStringConvertible {
    public var description: String {
        switch self {
        case .plain:
            return "Cleartext"
            
        case .https:
            return "HTTPS"
            
        case .tls:
            return "TLS"
        }
    }
}

extension VPNStatus: UIDescriptible {
    public var uiDescription: String {
        switch self {
        case .connecting:
            return L10n.Vpn.connecting
            
        case .connected:
            return L10n.Vpn.active
            
        case .disconnecting:
            return L10n.Vpn.disconnecting
            
        case .disconnected:
            return L10n.Vpn.inactive
        }
    }
}
