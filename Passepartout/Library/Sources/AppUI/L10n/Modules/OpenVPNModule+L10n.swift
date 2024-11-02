//
//  OpenVPNModule+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/18/24.
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

import CommonUtils
import Foundation
import PassepartoutKit

extension OpenVPN.PullMask: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .routes:
            return Strings.Global.routes

        case .dns:
            return Strings.Unlocalized.dns

        case .proxy:
            return Strings.Unlocalized.proxy
        }
    }
}

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
            return Strings.Global.disabled

        case .compLZO:
            return Strings.Unlocalized.OpenVPN.compLZO

        case .compress, .compressV2:
            return Strings.Unlocalized.OpenVPN.compress

        default:
            return Strings.Global.unknown
        }
    }
}

extension OpenVPN.CompressionAlgorithm: LocalizableEntity {
    public var localizedDescription: String {
        switch self {
        case .disabled:
            return Strings.Global.disabled

        case .LZO:
            return Strings.Unlocalized.OpenVPN.lzo

        case .other:
            return Strings.Entities.Openvpn.CompressionAlgorithm.other

        default:
            return Strings.Global.unknown
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
        let V = Strings.Unlocalized.OpenVPN.XOR.self
        switch self {
        case .xormask:
            return V.xormask.rawValue

        case .xorptrpos:
            return V.xorptrpos.rawValue

        case .reverse:
            return V.reverse.rawValue

        case .obfuscate:
            return V.obfuscate.rawValue
        }
    }

    private var longDescription: String {
        switch self {
        case .xormask(let mask):
            return "\(shortDescription) \(mask.zData.toHex())"

        case .obfuscate(let mask):
            return "\(shortDescription) \(mask.zData.toHex())"

        default:
            return shortDescription
        }
    }
}

extension OpenVPN.Configuration.Builder: StyledLocalizableEntity {
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

extension OpenVPN.Configuration.Builder: StyledOptionalLocalizableEntity {
    public enum OptionalStyle {
        case keepAlive

        case renegotiatesAfter

        case randomizeEndpoint

        case randomizeHostnames
    }

    public func localizedDescription(optionalStyle: OptionalStyle) -> String? {
        switch optionalStyle {
        case .keepAlive:
            return keepAliveInterval?.localizedDescription(style: .timeString)

        case .renegotiatesAfter:
            return renegotiatesAfter?.localizedDescription(style: .timeString)

        case .randomizeEndpoint:
            return randomizeEndpoint?.randomizeEndpointDescription

        case .randomizeHostnames:
            return randomizeHostnames?.randomizeHostnamesDescription
        }
    }
}

// MARK: - Raw types

private extension Optional where Wrapped == OpenVPN.TLSWrap {
    var tlsWrapDescription: String {
        guard let strategy = self?.strategy else {
            return Strings.Global.disabled
        }
        switch strategy {
        case .auth:
            return "--tls-auth"

        case .crypt:
            return "--tls-crypt"
        }
    }
}

private extension Optional where Wrapped == Bool {
    var ekuDescription: String {
        let V = Strings.Global.self
        return (self ?? false) ? V.enabled : V.disabled
    }
}

private extension Bool {
    var randomizeEndpointDescription: String {
        let V = Strings.Global.self
        return self ? V.enabled : V.disabled
    }

    var randomizeHostnamesDescription: String {
        let V = Strings.Global.self
        return self ? V.enabled : V.disabled
    }
}
