//
//  ParseError+L10n.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 11/25/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
internal import WireGuardKit

extension TunnelConfiguration.ParseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidLine(let line):
            return Strings.macAlertInvalidLine(String(line))
        case .noInterface:
            return Strings.macAlertNoInterface
        case .multipleInterfaces:
            return Strings.macAlertMultipleInterfaces
        case .interfaceHasNoPrivateKey:
            return composed(Strings.alertInvalidInterfaceMessagePrivateKeyRequired, Strings.alertInvalidInterfaceMessagePrivateKeyInvalid)
        case .interfaceHasInvalidPrivateKey:
            return composed(Strings.macAlertPrivateKeyInvalid, Strings.alertInvalidInterfaceMessagePrivateKeyInvalid)
        case .interfaceHasInvalidListenPort(let value):
            return composed(Strings.macAlertListenPortInvalid(value), Strings.alertInvalidInterfaceMessageListenPortInvalid)
        case .interfaceHasInvalidAddress(let value):
            return composed(Strings.macAlertAddressInvalid(value), Strings.alertInvalidInterfaceMessageAddressInvalid)
        case .interfaceHasInvalidDNS(let value):
            return composed(Strings.macAlertDNSInvalid(value), Strings.alertInvalidInterfaceMessageDNSInvalid)
        case .interfaceHasInvalidMTU(let value):
            return composed(Strings.macAlertMTUInvalid(value), Strings.alertInvalidInterfaceMessageMTUInvalid)
        case .interfaceHasUnrecognizedKey(let value):
            return composed(Strings.macAlertUnrecognizedInterfaceKey(value), Strings.macAlertInfoUnrecognizedInterfaceKey)
        case .peerHasNoPublicKey:
            return composed(Strings.alertInvalidPeerMessagePublicKeyRequired, Strings.alertInvalidPeerMessagePublicKeyInvalid)
        case .peerHasInvalidPublicKey:
            return composed(Strings.macAlertPublicKeyInvalid, Strings.alertInvalidPeerMessagePublicKeyInvalid)
        case .peerHasInvalidPreSharedKey:
            return composed(Strings.macAlertPreSharedKeyInvalid, Strings.alertInvalidPeerMessagePreSharedKeyInvalid)
        case .peerHasInvalidAllowedIP(let value):
            return composed(Strings.macAlertAllowedIPInvalid(value), Strings.alertInvalidPeerMessageAllowedIPsInvalid)
        case .peerHasInvalidEndpoint(let value):
            return composed(Strings.macAlertEndpointInvalid(value), Strings.alertInvalidPeerMessageEndpointInvalid)
        case .peerHasInvalidPersistentKeepAlive(let value):
            return composed(Strings.macAlertPersistentKeepliveInvalid(value), Strings.alertInvalidPeerMessagePersistentKeepaliveInvalid)
        case .peerHasUnrecognizedKey(let value):
            return composed(Strings.macAlertUnrecognizedPeerKey(value), Strings.macAlertInfoUnrecognizedPeerKey)
        case .peerHasInvalidTransferBytes(let line):
            return Strings.macAlertInvalidLine(String(line))
        case .peerHasInvalidLastHandshakeTime(let line):
            return Strings.macAlertInvalidLine(String(line))
        case .multiplePeersWithSamePublicKey:
            return Strings.alertInvalidPeerMessagePublicKeyDuplicated
        case .multipleEntriesForKey(let value):
            return Strings.macAlertMultipleEntriesForKey(value)
        }
    }
}

private typealias Strings = WireGuardStrings

private func composed(_ title: String, _ info: String) -> String {
    [title, info].joined(separator: " ")
}
