//
//  WireGuardView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/31/24.
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

import CommonLibrary
import PassepartoutKit
import PassepartoutWireGuardGo
import SwiftUI

struct WireGuardView: View, ModuleDraftEditing {

    @ObservedObject
    var editor: ProfileEditor

    let module: WireGuardModule.Builder

    var body: some View {
        contentView
            .moduleView(editor: editor, draft: draft.wrappedValue)
    }
}

// MARK: - Content

private extension WireGuardView {
    var configuration: WireGuard.Configuration.Builder {
        draft.wrappedValue.configurationBuilder ?? .default
    }

    @ViewBuilder
    var contentView: some View {
        moduleSection(for: interfaceRows, header: Strings.Modules.Wireguard.interface)
        moduleSection(for: dnsRows, header: Strings.Unlocalized.dns)
        ForEach(Array(zip(configuration.peers.indices, configuration.peers)), id: \.1.publicKey) { index, peer in
            moduleSection(for: peersRows(for: peer), header: Strings.Modules.Wireguard.peer(index + 1))
        }
    }
}

// MARK: - Subviews

private extension WireGuardView {
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

private extension WireGuardView {
    func importConfiguration(from url: URL) {
        // TODO: #657, import draft from external URL
    }
}

// MARK: - Previews

// swiftlint: disable force_try
#Preview {
    let gen = StandardWireGuardKeyGenerator()

    var builder = WireGuard.Configuration.Builder(keyGenerator: gen)
    builder.interface.addresses = ["1.1.1.1", "2.2.2.2"]
    builder.interface.mtu = 1200
    builder.interface.dns.protocolType = .cleartext
    builder.interface.dns.servers = ["8.8.8.8", "4.4.4.4"]
    builder.interface.dns.domainName = "domain.com"
    builder.interface.dns.searchDomains = ["search1.com", "search2.net"]

    builder.peers = (0..<3).map { _ in
        var peer = WireGuard.RemoteInterface.Builder(publicKey: try! gen.publicKey(for: gen.newPrivateKey()))
        peer.preSharedKey = gen.newPrivateKey()
        peer.allowedIPs = ["1.1.1.1/8", "2.2.2.2/12"]
        peer.endpoint = "8.8.8.8:12345"
        peer.keepAlive = 30
        return peer
    }

    let module = WireGuardModule.Builder(configurationBuilder: builder)
    return module.preview()
}
// swiftlint: enable force_try
