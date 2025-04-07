//
//  ParseError+L10n.swift
//  Partout
//
//  Created by Davide De Rosa on 11/25/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
internal import WireGuardKit

extension TunnelConfiguration.ParseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidLine(let line):
            return tr("macAlertInvalidLine", String(line))
        case .noInterface:
            return tr("macAlertNoInterface")
        case .multipleInterfaces:
            return tr("macAlertMultipleInterfaces")
        case .interfaceHasNoPrivateKey:
            return composed(tr("alertInvalidInterfaceMessagePrivateKeyRequired"), tr("alertInvalidInterfaceMessagePrivateKeyInvalid"))
        case .interfaceHasInvalidPrivateKey:
            return composed(tr("macAlertPrivateKeyInvalid"), tr("alertInvalidInterfaceMessagePrivateKeyInvalid"))
        case .interfaceHasInvalidListenPort(let value):
            return composed(tr("macAlertListenPortInvalid", value), tr("alertInvalidInterfaceMessageListenPortInvalid"))
        case .interfaceHasInvalidAddress(let value):
            return composed(tr("macAlertAddressInvalid", value), tr("alertInvalidInterfaceMessageAddressInvalid"))
        case .interfaceHasInvalidDNS(let value):
            return composed(tr("macAlertDNSInvalid", value), tr("alertInvalidInterfaceMessageDNSInvalid"))
        case .interfaceHasInvalidMTU(let value):
            return composed(tr("macAlertMTUInvalid", value), tr("alertInvalidInterfaceMessageMTUInvalid"))
        case .interfaceHasUnrecognizedKey(let value):
            return composed(tr("macAlertUnrecognizedInterfaceKey", value), tr("macAlertInfoUnrecognizedInterfaceKey"))
        case .peerHasNoPublicKey:
            return composed(tr("alertInvalidPeerMessagePublicKeyRequired"), tr("alertInvalidPeerMessagePublicKeyInvalid"))
        case .peerHasInvalidPublicKey:
            return composed(tr("macAlertPublicKeyInvalid"), tr("alertInvalidPeerMessagePublicKeyInvalid"))
        case .peerHasInvalidPreSharedKey:
            return composed(tr("macAlertPreSharedKeyInvalid"), tr("alertInvalidPeerMessagePreSharedKeyInvalid"))
        case .peerHasInvalidAllowedIP(let value):
            return composed(tr("macAlertAllowedIPInvalid", value), tr("alertInvalidPeerMessageAllowedIPsInvalid"))
        case .peerHasInvalidEndpoint(let value):
            return composed(tr("macAlertEndpointInvalid", value), tr("alertInvalidPeerMessageEndpointInvalid"))
        case .peerHasInvalidPersistentKeepAlive(let value):
            return composed(tr("macAlertPersistentKeepliveInvalid", value), tr("alertInvalidPeerMessagePersistentKeepaliveInvalid"))
        case .peerHasUnrecognizedKey(let value):
            return composed(tr("macAlertUnrecognizedPeerKey", value), tr("macAlertInfoUnrecognizedPeerKey"))
        case .peerHasInvalidTransferBytes(let line):
            return tr("macAlertInvalidLine", line)
        case .peerHasInvalidLastHandshakeTime(let line):
            return tr("macAlertInvalidLine", line)
        case .multiplePeersWithSamePublicKey:
            return tr("alertInvalidPeerMessagePublicKeyDuplicated")
        case .multipleEntriesForKey(let value):
            return tr("macAlertMultipleEntriesForKey", value)
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
