//
//  WireGuardView+Configuration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
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

import PassepartoutKit
import SwiftUI

extension WireGuardView {
    struct ConfigurationView: View {
        let configuration: WireGuard.Configuration.Builder

        var body: some View {
            moduleSection(for: interfaceRows, header: Strings.Modules.Wireguard.interface)
            moduleSection(for: dnsRows, header: Strings.Unlocalized.dns)
            ForEach(Array(zip(configuration.peers.indices, configuration.peers)), id: \.1.publicKey) { index, peer in
                moduleSection(for: peersRows(for: peer), header: Strings.Modules.Wireguard.peer(index + 1))
            }
        }
    }
}

private extension WireGuardView.ConfigurationView {
    var interfaceRows: [ModuleRow]? {
        var rows: [ModuleRow] = []
        rows.append(.longContent(caption: Strings.Global.privateKey, value: configuration.interface.privateKey))
        configuration.interface.addresses
            .nilIfEmpty
            .map {
                rows.append(.textList(
                    caption: Strings.Global.addresses,
                    values: $0
                ))
            }
        configuration.interface.mtu.map {
            rows.append(.text(caption: Strings.Unlocalized.mtu, value: $0.description))
        }
        return rows.nilIfEmpty
    }

    var dnsRows: [ModuleRow]? {
        var rows: [ModuleRow] = []

        configuration.interface.dns.servers
            .nilIfEmpty
            .map {
                rows.append(.textList(
                    caption: Strings.Global.servers,
                    values: $0
                ))
            }

        configuration.interface.dns.domainName.map {
            rows.append(.text(
                caption: Strings.Global.domain,
                value: $0
            ))
        }

        configuration.interface.dns.searchDomains?
            .nilIfEmpty
            .map {
                rows.append(.textList(
                    caption: Strings.Entities.Dns.searchDomains,
                    values: $0
                ))
            }

        return rows.nilIfEmpty
    }

    func peersRows(for peer: WireGuard.RemoteInterface.Builder) -> [ModuleRow]? {
        var rows: [ModuleRow] = []
        rows.append(.longContent(caption: Strings.Global.publicKey, value: peer.publicKey))
        peer.preSharedKey.map {
            rows.append(.longContent(caption: Strings.Modules.Wireguard.presharedKey, value: $0))
        }
        peer.endpoint.map {
            rows.append(.copiableText(caption: Strings.Global.endpoint, value: $0))
        }
        peer.allowedIPs
            .nilIfEmpty
            .map {
                rows.append(.textList(
                    caption: Strings.Modules.Wireguard.allowedIps,
                    values: $0
                ))
            }
        peer.keepAlive.map {
            rows.append(.text(caption: Strings.Global.keepAlive, value: TimeInterval($0).localizedDescription(style: .timeString)))
        }
        return rows.nilIfEmpty
    }
}
