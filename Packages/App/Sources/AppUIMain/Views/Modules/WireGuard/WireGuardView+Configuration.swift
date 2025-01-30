//
//  WireGuardView+Configuration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
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

import PassepartoutKit
import SwiftUI

extension WireGuardView {
    struct ConfigurationView: View {

        @Binding
        var configuration: WireGuard.Configuration.Builder

        var body: some View {
            interfaceSection
            dnsSection
            ForEach(Array(zip(configuration.peers.indices, configuration.peers)), id: \.1.publicKey) { index, peer in
                peerSection(for: peer, at: index)
            }
        }
    }
}

private extension WireGuardView.ConfigurationView {
    var interfaceSection: some View {
        themeModuleSection(header: Strings.Modules.Wireguard.interface) {
            ThemeModuleLongContent(
                caption: Strings.Global.Nouns.privateKey,
                value: configuration.interface.privateKey
            )
            ThemeModuleTextList(
                caption: Strings.Global.Nouns.addresses,
                values: configuration.interface.addresses
            )
            configuration.interface.mtu.map {
                ThemeModuleText(
                    caption: Strings.Unlocalized.mtu,
                    value: $0.description
                )
            }
        }
    }

    var dnsSection: some View {
        themeModuleSection(if: dnsRows, header: Strings.Unlocalized.dns) {
            ThemeModuleTextList(
                caption: Strings.Global.Nouns.servers,
                values: configuration.interface.dns.servers
            )
            configuration.interface.dns.domainName
                .map {
                    ThemeModuleText(
                        caption: Strings.Global.Nouns.domain,
                        value: $0
                    )
                }
            configuration.interface.dns.searchDomains?
                .nilIfEmpty
                .map {
                    ThemeModuleTextList(
                        caption: Strings.Entities.Dns.searchDomains,
                        values: $0
                    )
                }
        }
    }

    func peerSection(for peer: WireGuard.RemoteInterface.Builder, at index: Int) -> some View {
        themeModuleSection(header: Strings.Modules.Wireguard.peer(index + 1)) {
            ThemeModuleLongContent(
                caption: Strings.Global.Nouns.publicKey,
                value: .constant(peer.publicKey)
            )
            peer.preSharedKey
                .map {
                    ThemeModuleLongContent(
                        caption: Strings.Modules.Wireguard.presharedKey,
                        value: .constant($0)
                    )
                }
            peer.endpoint
                .map {
                    ThemeModuleCopiableText(
                        caption: Strings.Global.Nouns.endpoint,
                        value: $0
                    )
                }
            peer.allowedIPs
                .nilIfEmpty
                .map {
                    ThemeModuleTextList(
                        caption: Strings.Modules.Wireguard.allowedIps,
                        values: $0
                    )
                }
            peer.keepAlive
                .map {
                    ThemeModuleText(
                        caption: Strings.Global.Nouns.keepAlive,
                        value: TimeInterval($0).localizedDescription(style: .timeString))
                }
        }
    }
}

private extension WireGuardView.ConfigurationView {
    var dnsRows: [Any?] {
        [
            configuration.interface.dns.servers.nilIfEmpty,
            configuration.interface.dns.domainName,
            configuration.interface.dns.searchDomains?.nilIfEmpty
        ]
    }
}

// MARK: - Previews

#Preview {
    struct Preview: View {

        @State
        private var configuration: WireGuard.Configuration.Builder = .forPreviews

        var body: some View {
            NavigationStack {
                Form {
                    WireGuardView.ConfigurationView(
                        configuration: $configuration
                    )
                }
                .themeForm()
                .withMockEnvironment()
            }
        }
    }

    return Preview()
}
