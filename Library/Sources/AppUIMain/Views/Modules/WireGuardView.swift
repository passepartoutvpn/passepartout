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
import CommonUtils
import PassepartoutKit
import SwiftUI

struct WireGuardView: View, ModuleDraftEditing {

    @Environment(\.navigationPath)
    private var path

    @ObservedObject
    var editor: ProfileEditor

    let module: WireGuardModule.Builder

    let impl: WireGuardModule.Implementation?

    @State
    private var paywallReason: PaywallReason?

    @State
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        contentView
            .moduleView(editor: editor, draft: draft.wrappedValue)
            .modifier(PaywallModifier(reason: $paywallReason))
            .navigationDestination(for: Subroute.self, destination: destination)
            .themeAnimation(on: providerId.wrappedValue, category: .modules)
            .withErrorHandler(errorHandler)
    }
}

// MARK: - Content

private extension WireGuardView {

    @ViewBuilder
    var contentView: some View {
        if let configuration = draft.wrappedValue.configurationBuilder {
            ConfigurationView(configuration: configuration)
        } else {
            EmptyView()
                .modifier(providerModifier)
        }
    }

    var providerModifier: some ViewModifier {
        VPNProviderContentModifier(
            providerId: providerId,
            selectedEntity: providerEntity,
            paywallReason: $paywallReason,
            entityDestination: Subroute.providerServer,
            providerRows: {
                moduleGroup(for: providerKeyRows)
            }
        )
    }

    var providerKeyRows: [ModuleRow]? {
        [.push(caption: Strings.Modules.Wireguard.providerKey, route: HashableRoute(Subroute.providerKey))]
    }
}

private extension WireGuardView {
    func onSelectServer(server: VPNServer, preset: VPNPreset<WireGuard.Configuration>) {
        guard let providerId = providerId.wrappedValue else {
            return
        }
        providerEntity.wrappedValue = VPNEntity(providerId: providerId, server: server, preset: preset)
        path.wrappedValue.removeLast()
    }

    func importConfiguration(from url: URL) {
        // TODO: #657, import draft from external URL
    }
}

// MARK: - Destinations

private extension WireGuardView {
    enum Subroute: Hashable {
        case providerServer

        case providerKey
    }

    @ViewBuilder
    func destination(for route: Subroute) -> some View {
        switch route {
        case .providerServer:
            draft.providerSelection.wrappedValue.map {
                VPNProviderServerView(
                    moduleId: module.id,
                    providerId: $0.id,
                    configurationType: WireGuard.Configuration.self,
                    selectedEntity: $0.entity,
                    filtersWithSelection: true,
                    onSelect: onSelectServer
                )
            }

        case .providerKey:
            // TODO: #339, WireGuard upload public key to provider
            EmptyView()
        }
    }
}

// MARK: - Previews

// swiftlint: disable force_try
#Preview {
    let gen = MockGenerator()

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

private final class MockGenerator: WireGuardKeyGenerator {
    func newPrivateKey() -> String {
        "private-key"
    }

    func privateKey(from string: String) throws -> String {
        "private-key"
    }

    func publicKey(from string: String) throws -> String {
        "public-key"
    }

    func publicKey(for privateKey: String) throws -> String {
        "public-key"
    }
}
