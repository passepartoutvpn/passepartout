//
//  EndpointAdvancedView+OpenVPN.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/8/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import TunnelKitOpenVPN
import PassepartoutCore

extension EndpointAdvancedView {
    struct OpenVPNView: View {
        @Binding var builder: OpenVPN.ConfigurationBuilder

        let isReadonly: Bool
        
        let isServerPushed: Bool
        
        var body: some View {
            List {
                let cfg = builder.build()
                if isServerPushed {
                    ipv4Section
                    ipv6Section
                }
                dnsSection(configuration: cfg)
                proxySection(configuration: cfg)
                if !isReadonly {
                    communicationEditableSection
                    compressionEditableSection
                } else {
                    communicationSection(configuration: cfg)
                    compressionSection(configuration: cfg)
                }
                if !isServerPushed {
                    tlsSection
                }
                otherSection(configuration: cfg)
            }
        }
    }
}

extension EndpointAdvancedView.OpenVPNView {
    private var ipv4Section: some View {
        builder.ipv4.map { cfg in
            Section(
                header: Text(Unlocalized.Network.ipv4)
            ) {
                Text(L10n.Global.Strings.address)
                    .withTrailingText(builder.ipv4.localizedAddress, copyOnTap: true)
                Text(L10n.NetworkSettings.Gateway.title)
                    .withTrailingText(builder.ipv4.localizedDefaultGateway, copyOnTap: true)
            
                ForEach(cfg.routes, id: \.self) { route in
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.Route.caption)
                        .withTrailingText(route.localizedDescription, copyOnTap: true)
                }
            }
        }
    }
    
    private var ipv6Section: some View {
        builder.ipv6.map { cfg in
            Section(
                header: Text(Unlocalized.Network.ipv6)
            ) {
                Text(L10n.Global.Strings.address)
                    .withTrailingText(builder.ipv6.localizedAddress, copyOnTap: true)

                Text(L10n.NetworkSettings.Gateway.title)
                    .withTrailingText(builder.ipv6.localizedDefaultGateway, copyOnTap: true)

                ForEach(cfg.routes, id: \.self) { route in
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.Route.caption)
                        .withTrailingText(route.localizedDescription, copyOnTap: true)
                }
            }
        }
    }

    private func communicationSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.communicationSettings.map { settings in
            Section(
                header: Text(L10n.Endpoint.Advanced.Openvpn.Sections.Communication.header)
            ) {
                settings.cipher.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.Cipher.caption)
                        .withTrailingText($0.localizedDescription)
                }
                settings.digest.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.Digest.caption)
                        .withTrailingText($0.localizedDescription)
                }
                settings.xor.map {
                    Text(Unlocalized.VPN.xor)
                        .withTrailingText($0.localizedDescriptionAsXOR)
                }
            }
        }
    }
    
    private var communicationEditableSection: some View {
        Section(
            header: Text(L10n.Endpoint.Advanced.Openvpn.Sections.Communication.header)
        ) {
            themeTextPicker(
                L10n.Endpoint.Advanced.Openvpn.Items.Cipher.caption,
                selection: $builder.cipher ?? OpenVPN.Configuration.Fallback.cipher,
                values: OpenVPN.Cipher.available,
                description: \.localizedDescription
            )
            themeTextPicker(
                L10n.Endpoint.Advanced.Openvpn.Items.Digest.caption,
                selection: $builder.digest ?? OpenVPN.Configuration.Fallback.digest,
                values: OpenVPN.Digest.available,
                description: \.localizedDescription
            )
            builder.xorMask.map {
                Text(Unlocalized.VPN.xor)
                    .withTrailingText($0.localizedDescriptionAsXOR)
            }
        }
    }
    
    private func compressionSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.compressionSettings.map { settings in
            Section(
                header: Text(L10n.Endpoint.Advanced.Openvpn.Sections.Compression.header)
            ) {
                settings.framing.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.CompressionFraming.caption)
                        .withTrailingText($0.localizedDescription)
                }
                settings.algorithm.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.CompressionAlgorithm.caption)
                        .withTrailingText($0.localizedDescription)
                }
            }
        }
    }
    
    private var compressionEditableSection: some View {
        Section(
            header: Text(L10n.Endpoint.Advanced.Openvpn.Sections.Compression.header)
        ) {
            themeTextPicker(
                L10n.Endpoint.Advanced.Openvpn.Items.CompressionFraming.caption,
                selection: $builder.compressionFraming ?? OpenVPN.Configuration.Fallback.compressionFraming,
                values: OpenVPN.CompressionFraming.available,
                description: \.localizedDescription
            )
            themeTextPicker(
                L10n.Endpoint.Advanced.Openvpn.Items.CompressionAlgorithm.caption,
                selection: $builder.compressionAlgorithm ?? OpenVPN.Configuration.Fallback.compressionAlgorithm,
                values: OpenVPN.CompressionAlgorithm.available,
                description: \.localizedDescription
            ).disabled(builder.compressionFraming == .disabled)
        }
    }

    private func dnsSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.dnsSettings.map { settings in
            Section(
                header: Text(Unlocalized.Network.dns)
            ) {
                ForEach(settings.servers, id: \.self) {
                    Text(L10n.Global.Strings.address)
                        .withTrailingText($0)
                }
                ForEach(settings.domains, id: \.self) {
                    Text(L10n.Global.Strings.domain)
                        .withTrailingText($0)
                }
            }
        }
    }

    private func proxySection(configuration: OpenVPN.Configuration) -> some View {
        configuration.proxySettings.map { settings in
            Section(
                header: Text(L10n.Global.Strings.proxy)
            ) {
                settings.proxy.map {
                    Text(L10n.Global.Strings.address)
                        .withTrailingText($0.rawValue)
                }
                settings.pac.map {
                    Text(Unlocalized.Network.proxyAutoConfiguration)
                        .withTrailingText($0.absoluteString)
                }
                ForEach(settings.bypass, id: \.self) {
                    Text(L10n.NetworkSettings.Items.ProxyBypass.caption)
                        .withTrailingText($0)
                }
            }
        }
    }

    private var tlsSection: some View {
        Section(
            header: Text(Unlocalized.Network.tls)
        ) {
            builder.ca.map { ca in
                themeLongContentLink(
                    Unlocalized.VPN.certificateAuthority,
                    content: .constant(ca.pem)
                )
            }
            builder.clientCertificate.map { cert in
                themeLongContentLink(
                    L10n.Endpoint.Advanced.Openvpn.Items.Client.caption,
                    content: .constant(cert.pem)
                )
            }
            builder.clientKey.map { key in
                themeLongContentLink(
                    L10n.Endpoint.Advanced.Openvpn.Items.ClientKey.caption,
                    content: .constant(key.pem)
                )
            }
            builder.tlsWrap.map { wrap in
                themeLongContentLink(
                    L10n.Endpoint.Advanced.Openvpn.Items.TlsWrapping.caption,
                    content: .constant(wrap.key.hexString),
                    withPreview: builder.tlsWrap.localizedDescription
                )
            }
            Text(L10n.Endpoint.Advanced.Openvpn.Items.Eku.caption)
                .withTrailingText(builder.checksEKU.localizedDescriptionAsEKU)
        }
    }

    private func otherSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.otherSettings.map { settings in
            Section(
                header: Text(L10n.Endpoint.Advanced.Openvpn.Sections.Other.header)
            ) {
                settings.keepAlive.map {
                    Text(L10n.Global.Strings.keepalive)
                        .withTrailingText($0.localizedDescriptionAsKeepAlive)
                }
                settings.reneg.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.RenegotiationSeconds.caption)
                        .withTrailingText($0.localizedDescriptionAsRenegotiatesAfter)
                }
                settings.randomize.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.RandomEndpoint.caption)
                        .withTrailingText($0.localizedDescriptionAsRandomizeEndpoint)
                }
            }
        }
    }
}

extension OpenVPN.Configuration {
    var communicationSettings: (cipher: OpenVPN.Cipher?, digest: OpenVPN.Digest?, xor: UInt8?)? {
        guard cipher != nil || digest != nil || xorMask != nil else {
            return nil
        }
        return (cipher, digest, xorMask)
    }

    var compressionSettings: (framing: OpenVPN.CompressionFraming?, algorithm: OpenVPN.CompressionAlgorithm?)? {
        guard compressionFraming != nil || compressionAlgorithm != nil else {
            return nil
        }
        return (compressionFraming, compressionAlgorithm)
    }
    
    var dnsSettings: (servers: [String], domains: [String])? {
        guard !(dnsServers?.isEmpty ?? true) || !(searchDomains?.isEmpty ?? true) else {
            return nil
        }
        return (dnsServers ?? [], searchDomains ?? [])
    }
    
    var proxySettings: (proxy: Proxy?, pac: URL?, bypass: [String])? {
        guard httpsProxy != nil || httpProxy != nil || proxyAutoConfigurationURL != nil || !(proxyBypassDomains?.isEmpty ?? true) else {
            return nil
        }
        return (httpsProxy ?? httpProxy, proxyAutoConfigurationURL, proxyBypassDomains ?? [])
    }
    
    var otherSettings: (keepAlive: TimeInterval?, reneg: TimeInterval?, randomize: Bool?)? {
        guard keepAliveInterval != nil || renegotiatesAfter != nil || randomizeEndpoint != nil else {
            return nil
        }
        return (keepAliveInterval, renegotiatesAfter, randomizeEndpoint)
    }
}
