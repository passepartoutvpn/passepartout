//
//  EndpointAdvancedView+WireGuard.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/8/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import SwiftUI
import TunnelKitWireGuard

extension EndpointAdvancedView {
    struct WireGuardView: View {
        @Binding var builder: WireGuard.ConfigurationBuilder

        let isReadonly: Bool

        var body: some View {
            List {
                let cfg = builder.build()
                keySection
                addressesSection
                dnsSection(configuration: cfg)
                mtuSection
            }
        }
    }
}

extension EndpointAdvancedView.WireGuardView {
    private var keySection: some View {
        Section {
            themeLongContentLink(L10n.Global.Strings.privateKey, content: .constant(builder.privateKey))
            themeLongContentLink(L10n.Global.Strings.publicKey, content: .constant(builder.publicKey))
        } header: {
            Text(L10n.Global.Strings.interface)
        }
    }

    private var addressesSection: some View {
        Section {
            ForEach(builder.addresses, id: \.self, content: Text.init)
        } header: {
            Text(L10n.Global.Strings.addresses)
        }
    }

    private func dnsSection(configuration: WireGuard.Configuration) -> some View {
        configuration.dnsSettings.map { settings in
            Section {
                ForEach(settings.servers, id: \.self) {
                    Text(L10n.Global.Strings.address)
                        .withTrailingText($0)
                }
                ForEach(settings.domains, id: \.self) {
                    Text(L10n.Global.Strings.domain)
                        .withTrailingText($0)
                }
            } header: {
                Text(Unlocalized.Network.dns)
            }
        }
    }

    private var mtuSection: some View {
        builder.mtu.map { mtu in
            Section {
                Text(Unlocalized.Network.mtu)
                    .withTrailingText(Int(mtu).localizedDescriptionAsMTU)
            }
        }
    }
}

private extension WireGuard.Configuration {
    struct DNSOptions {
        let servers: [String]

        let domains: [String]
    }

    var dnsSettings: DNSOptions? {
        guard !dnsServers.isEmpty || !dnsSearchDomains.isEmpty else {
            return nil
        }
        return .init(servers: dnsServers, domains: dnsSearchDomains)
    }
}
