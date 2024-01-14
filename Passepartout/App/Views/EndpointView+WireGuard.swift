//
//  EndpointView+WireGuard.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
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

#if !os(tvOS)
import PassepartoutLibrary
import SwiftUI
import TunnelKitWireGuard

extension EndpointView {
    struct WireGuardView: View {
        @ObservedObject private var providerManager: ProviderManager

        @ObservedObject private var currentProfile: ObservableProfile

        let isReadonly: Bool

        @Binding private var builder: WireGuard.ConfigurationBuilder

//        var customPeer: Binding<Endpoint?>? = nil

        init(currentProfile: ObservableProfile, isReadonly: Bool) {
            let providerManager: ProviderManager = .shared

            self.providerManager = providerManager
            self.currentProfile = currentProfile
            self.isReadonly = isReadonly

            _builder = currentProfile.builderBinding(providerManager: providerManager)
        }

        var body: some View {
            List {
                peersSections
                advancedSection
            }.navigationTitle(L10n.Global.Strings.endpoint)
        }
    }
}

// MARK: -

private extension EndpointView.WireGuardView {
    var peersSections: some View {

        // TODO: WireGuard, make peers editable
//        if !isReadonly {
            ForEach(0..<builder.peersCount, id: \.self) {
                section(forPeerAt: $0)
            }
//        } else {
//            ForEach(builder.peers.indices, id: \.self) {
//                section(forPeer: builder.peers[$0], at: $0)
//            }
//        }
    }

    func section(forPeerAt peerIndex: Int) -> some View {
        Section {
            themeLongContentLink(
                L10n.Global.Strings.publicKey,
                content: .constant(builder.publicKey(ofPeer: peerIndex))
            )
            builder.preSharedKey(ofPeer: peerIndex).map { key in
                themeLongContentLink(
                    L10n.Endpoint.Wireguard.Items.PresharedKey.caption,
                    content: .constant(key)
                )
            }
            builder.endpoint(ofPeer: peerIndex).map {
                Text(L10n.Global.Strings.endpoint)
                    .withTrailingText($0)
            }
            ForEach(builder.allowedIPs(ofPeer: peerIndex), id: \.self) {
                Text(L10n.Endpoint.Wireguard.Items.AllowedIp.caption)
                    .withTrailingText($0)
            }
            builder.localizedDescription(optionalStyle: .keepAlive(peerIndex: peerIndex)).map {
                Text(L10n.Global.Strings.keepalive)
                    .withTrailingText($0)
            }
        } header: {
            Text(L10n.Endpoint.Wireguard.Items.Peer.caption)
        }
    }

    var advancedSection: some View {
        Section {
            let caption = L10n.Endpoint.Advanced.title
            NavigationLink(caption) {
                EndpointAdvancedView.WireGuardView(
                    builder: $builder,
                    isReadonly: isReadonly
                ).navigationTitle(caption)
            }
        }
    }
}

// MARK: - Bindings

private extension ObservableProfile {

    @MainActor
    func builderBinding(providerManager: ProviderManager) -> Binding<WireGuard.ConfigurationBuilder> {
        .init {
            if self.value.isProvider {
                guard let server = self.value.providerServer(providerManager) else {
                    assertionFailure("Server not found")
                    return .init()
                }
                guard let preset = self.value.providerPreset(server) else {
                    assertionFailure("Preset not found")
                    return .init()
                }
                guard let cfg = preset.wireGuardConfiguration else {
                    assertionFailure("Preset \(preset.id) (\(preset.name)) has no WireGuard configuration")
                    return .init()
                }
                return cfg.builder()
            } else if let cfg = self.value.hostWireGuardSettings?.configuration {
                let builder = cfg.builder()
//                pp_log.debug("Loading WireGuard configuration: \(builder)")
                return builder
            }
            // fall back gracefully
            return .init()
        } set: {
            if self.value.isProvider {
                // readonly
            } else {
                pp_log.verbose("Saving WireGuard configuration: \($0)")
                self.value.hostWireGuardSettings?.configuration = $0.build()
            }
        }
    }
}
#endif
