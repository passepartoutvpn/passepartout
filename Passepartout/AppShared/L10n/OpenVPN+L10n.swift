//
//  OpenVPN+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/26/22.
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

extension OpenVPN.Cipher {
    var localizedDescription: String {
        description
    }
}

extension OpenVPN.Digest {
    var localizedDescription: String {
        description
    }
}

extension UInt8 {
    var localizedDescriptionAsXOR: String {
        let V = L10n.Global.Strings.self
        guard self != 0 else {
            return V.disabled
        }
        return String(format: "0x%02x", UInt8(self))
    }
}

extension OpenVPN.CompressionFraming {
    var localizedDescription: String {
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

extension OpenVPN.CompressionAlgorithm {
    var localizedDescription: String {
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

extension Optional where Wrapped == OpenVPN.TLSWrap {
    var localizedDescription: String {
        let V = L10n.Endpoint.Advanced.Openvpn.Items.self
        if let strategy = self?.strategy {
            switch strategy {
            case .auth:
                return V.TlsWrapping.Value.auth

            case .crypt:
                return V.TlsWrapping.Value.crypt
            }
        } else {
            return L10n.Global.Strings.disabled
        }
    }
}

extension Optional where Wrapped == Bool {
    var localizedDescriptionAsEKU: String {
        let V = L10n.Global.Strings.self
        return (self ?? false) ? V.enabled : V.disabled
    }
}

extension TimeInterval {
    var localizedDescriptionAsRenegotiatesAfter: String {
        let V = L10n.Endpoint.Advanced.Openvpn.Items.self
        if self > 0 {
            return V.RenegotiationSeconds.Value.after(TimeInterval(self).localizedDescription)
        } else {
            return L10n.Global.Strings.disabled
        }
    }
}

extension Bool {
    var localizedDescriptionAsRandomizeEndpoint: String {
        let V = L10n.Global.Strings.self
        return self ? V.enabled : V.disabled
    }
    
    var localizedDescriptionAsRandomizeHostnames: String {
        let V = L10n.Global.Strings.self
        return self ? V.enabled : V.disabled
    }
}

extension OpenVPN.PullMask {
    var localizedDescription: String {
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
