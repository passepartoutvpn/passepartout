//
//  WireGuard+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/25/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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
import Partout

extension WireGuardParseError: @retroactive LocalizedError {
    public var errorDescription: String? {
        let V = Strings.Errors.Wireguard.self
        switch self {
        case .invalidLine(let line):
            return V.Title.invalidLine(line)
        case .noInterface:
            return V.Title.noInterface
        case .multipleInterfaces:
            return V.Title.multipleInterfaces
        case .interfaceHasNoPrivateKey:
            return composed(V.Interface.messagePrivateKeyRequired, V.Interface.messagePrivateKeyInvalid)
        case .interfaceHasInvalidPrivateKey:
            return composed(V.Title.privateKeyInvalid, V.Interface.messagePrivateKeyInvalid)
        case .interfaceHasInvalidListenPort(let value):
            return composed(V.Title.listenPortInvalid(value), V.Interface.messageListenPortInvalid)
        case .interfaceHasInvalidAddress(let value):
            return composed(V.Title.addressInvalid(value), V.Interface.messageAddressInvalid)
        case .interfaceHasInvalidDNS(let value):
            return composed(V.Title.dnsInvalid(value), V.Interface.messageDNSInvalid)
        case .interfaceHasInvalidMTU(let value):
            return composed(V.Title.mtuInvalid(value), V.Interface.messageMTUInvalid)
        case .interfaceHasUnrecognizedKey(let value):
            return composed(V.Title.unrecognizedInterfaceKey(value), V.Title.infoUnrecognizedInterfaceKey)
        case .peerHasNoPublicKey:
            return composed(V.Peer.messagePublicKeyRequired, V.Peer.messagePublicKeyInvalid)
        case .peerHasInvalidPublicKey:
            return composed(V.Title.publicKeyInvalid, V.Peer.messagePublicKeyInvalid)
        case .peerHasInvalidPreSharedKey:
            return composed(V.Title.preSharedKeyInvalid, V.Peer.messagePreSharedKeyInvalid)
        case .peerHasInvalidAllowedIP(let value):
            return composed(V.Title.allowedIPInvalid(value), V.Peer.messageAllowedIPsInvalid)
        case .peerHasInvalidEndpoint(let value):
            return composed(V.Title.endpointInvalid(value), V.Peer.messageEndpointInvalid)
        case .peerHasInvalidPersistentKeepAlive(let value):
            return composed(V.Title.persistentKeepliveInvalid(value), V.Peer.messagePersistentKeepaliveInvalid)
        case .peerHasUnrecognizedKey(let value):
            return composed(V.Title.unrecognizedPeerKey(value), V.Title.infoUnrecognizedPeerKey)
        case .peerHasInvalidTransferBytes(let line):
            return V.Title.invalidLine(line)
        case .peerHasInvalidLastHandshakeTime(let line):
            return V.Title.invalidLine(line)
        case .multiplePeersWithSamePublicKey:
            return V.Peer.messagePublicKeyDuplicated
        case .multipleEntriesForKey(let value):
            return V.Title.multipleEntriesForKey(value)
        }
    }
}

private func tr(_ key: String) -> String {
    NSLocalizedString(key, bundle: .module, comment: "")
}

private func tr(_ format: String, _ arguments: CVarArg...) -> String {
    String(format: tr(format), arguments: arguments)
}

private func composed(_ title: String, _ info: String) -> String {
    [title, info].joined(separator: " ")
}
