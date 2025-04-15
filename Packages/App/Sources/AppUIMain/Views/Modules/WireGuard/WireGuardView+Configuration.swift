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

import CommonLibrary
import SwiftUI

extension WireGuardView {
    struct ConfigurationView: View {

        @Binding
        var configuration: WireGuard.Configuration.Builder

        let keyGenerator: WireGuardKeyGenerator?

        @State
        private var model = ViewModel()

        var body: some View {
            Group {
                privateKeySection
                interfaceSection
                dnsSection
                ForEach(Array(zip(model.peersOrder.indices, model.peersOrder)), id: \.1) { index, publicKey in
                    peerSection(for: publicKey, at: index)
                }
                Section {
                    ThemeTrailingContent(content: addPeerButton)
                }
            }
            .onLoad {
                model.load(from: configuration)
            }
            .onChange(of: configuration) {
                model.load(from: $0)
            }
            .onChange(of: model) {
                $0.save(to: &configuration)
            }
        }
    }
}

private extension WireGuardView.ConfigurationView {
    var privateKeySection: some View {
        themeModuleSection(header: Strings.Modules.Wireguard.interface) {
            ThemeLongContentLink(
                Strings.Global.Nouns.privateKey,
                text: $model.privateKey
            )
            if let keyGenerator {
                ThemeCopiableText(
                    Strings.Global.Nouns.publicKey,
                    value: (try? keyGenerator.publicKey(for: model.privateKey)) ?? ""
                )
                Button(Strings.Modules.Wireguard.PrivateKey.generate) {
                    model.privateKey = keyGenerator.newPrivateKey()
                }
            }
        }
    }

    var interfaceSection: some View {
        themeModuleSection(header: nil) {
            ThemeLongContentLink(
                Strings.Global.Nouns.addresses,
                text: $model.addresses,
                preview: \.asNumberOfEntries
            )
            ThemeTextField(
                Strings.Unlocalized.mtu,
                text: $model.mtu,
                placeholder: Strings.Unlocalized.Placeholders.mtu
            )
        }
    }

    var dnsSection: some View {
        themeModuleSection(header: Strings.Unlocalized.dns) {
            ThemeLongContentLink(
                Strings.Global.Nouns.servers,
                text: $model.dnsServers,
                preview: \.asNumberOfEntries
            )
            ThemeTextField(
                Strings.Global.Nouns.domain,
                text: $model.dnsDomain,
                placeholder: Strings.Unlocalized.Placeholders.hostname
            )
            ThemeLongContentLink(
                Strings.Entities.Dns.searchDomains,
                text: $model.dnsSearchDomains,
                preview: \.asNumberOfEntries
            )
        }
    }

    func peerSection(for publicKey: String, at index: Int) -> some View {
        themeModuleSection(header: Strings.Modules.Wireguard.peer(index + 1)) {
            let peerBinding = peerBinding(with: publicKey)

            ThemeLongContentLink(
                Strings.Global.Nouns.publicKey,
                text: peerBinding.publicKey
            )
            ThemeLongContentLink(
                Strings.Modules.Wireguard.presharedKey,
                text: peerBinding.preSharedKey
            )
            ThemeLongContentLink(
                Strings.Global.Nouns.endpoint,
                text: peerBinding.endpoint
            )
            ThemeLongContentLink(
                Strings.Modules.Wireguard.allowedIps,
                text: peerBinding.allowedIPs,
                preview: \.asNumberOfEntries
            )
            ThemeTextField(
                Strings.Global.Nouns.keepAlive,
                text: peerBinding.keepAlive,
                placeholder: Strings.Unlocalized.Placeholders.keepAlive
            )
            ThemeTrailingContent {
                removePeerButton(at: index, publicKey: publicKey)
            }
        }
    }

    func addPeerButton() -> some View {
        Button(Strings.Modules.Wireguard.Peer.add) {
            let newPeer = ViewModel.Peer()
            assert(newPeer.publicKey == "")
            withAnimation {
                model.peers[newPeer.publicKey] = newPeer
                model.peersOrder.append(newPeer.publicKey)
            }
        }
        .disabled(model.peers[""] != nil)
    }

    func removePeerButton(at index: Int, publicKey: String) -> some View {
        Button(Strings.Modules.Wireguard.Peer.delete, role: .destructive) {
            withAnimation {
                model.peersOrder.remove(at: index)
                model.peers.removeValue(forKey: publicKey)
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

// MARK: - Logic

private extension WireGuardView.ConfigurationView {
    struct ViewModel: Equatable {
        struct Peer: Equatable {
            var publicKey = ""

            var preSharedKey = ""

            var endpoint = ""

            var allowedIPs = ""

            var keepAlive = ""
        }

        private let separator = ","

        var privateKey = ""

        var addresses = ""

        var mtu = ""

        var dnsServers = ""

        var dnsDomain = ""

        var dnsSearchDomains = ""

        var peers: [String: Peer] = [:]

        var peersOrder: [String] = []

        mutating func load(from configuration: WireGuard.Configuration.Builder) {
            privateKey = configuration.interface.privateKey
            addresses = configuration.interface.addresses.joined(separator: separator)
            mtu = configuration.interface.mtu?.description ?? ""

            dnsServers = configuration.interface.dns.servers.joined(separator: separator)
            dnsDomain = configuration.interface.dns.domainName ?? ""
            dnsSearchDomains = configuration.interface.dns.searchDomains?.joined(separator: separator) ?? ""

            peers = configuration.peers.reduce(into: [:]) {
                var peer = Peer()
                peer.publicKey = $1.publicKey
                peer.preSharedKey = $1.preSharedKey ?? ""
                peer.endpoint = $1.endpoint ?? ""
                peer.allowedIPs = $1.allowedIPs.joined(separator: separator)
                peer.keepAlive = $1.keepAlive?.description ?? ""
                $0[$1.publicKey] = peer
            }
            peersOrder = configuration.peers.map(\.publicKey)
        }

        func save(to configuration: inout WireGuard.Configuration.Builder) {
            configuration.interface.privateKey = privateKey
            configuration.interface.addresses = addresses.trimmedSplit(separator: separator)
            configuration.interface.mtu = UInt16(mtu)

            var dns = DNSModule.Builder()
            dns.servers = dnsServers.trimmedSplit(separator: separator)
            dns.domainName = dnsDomain
            dns.searchDomains = dnsSearchDomains.trimmedSplit(separator: separator)
            configuration.interface.dns = dns

            configuration.peers = peersOrder
                .compactMap {
                    guard let model = peers[$0] else {
                        return nil
                    }
                    var peer = WireGuard.RemoteInterface.Builder(publicKey: model.publicKey)
                    peer.preSharedKey = model.preSharedKey
                    peer.endpoint = model.endpoint
                    peer.allowedIPs = model.allowedIPs.trimmedSplit(separator: separator)
                    peer.keepAlive = UInt16(model.keepAlive)
                    return peer
                }
        }
    }

    func peerBinding(with publicKey: String) -> Binding<ViewModel.Peer> {
        Binding {
            model.peers[publicKey] ?? ViewModel.Peer()
        } set: {
            model.peers[publicKey] = $0
        }
    }
}

private extension String {
    var asNumberOfEntries: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }
        let count = 1 + trimmed.ranges(of: ",").count
        return count.localizedEntries
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
                        configuration: $configuration,
                        keyGenerator: nil
                    )
                }
                .themeForm()
                .withMockEnvironment()
            }
        }
    }

    return Preview()
}
