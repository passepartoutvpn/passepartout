//
//  EndpointAdvancedView+OpenVPN.swift
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
import TunnelKitOpenVPN
import PassepartoutLibrary

extension EndpointAdvancedView {
    struct OpenVPNView: View {
        @Binding var builder: OpenVPN.ConfigurationBuilder

        let isReadonly: Bool

        let isServerPushed: Bool

        private let fallbackConfiguration = OpenVPN.ConfigurationBuilder(withFallbacks: true).build()

        var body: some View {
            List {
                let cfg = builder.build()
                if !isServerPushed {
                    pullSection(configuration: cfg)
                }
                if builder.ipv4 != nil || builder.routes4 != nil {
                    ipv4Section
                }
                if builder.ipv6 != nil || builder.routes6 != nil {
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
    private func pullSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.pullMask.map { mask in
            Section {
                ForEach(mask, id: \.self) {
                    Text($0.localizedDescription)
                }
            } header: {
                Text(L10n.Endpoint.Advanced.Openvpn.Sections.Pull.header)
            }
        }
    }

    private var ipv4Section: some View {
        Section {
            if let settings = builder.ipv4 {
                themeLongContentLinkDefault(
                    L10n.Global.Strings.address,
                    content: .constant(settings.localizedAddress)
                )
                themeLongContentLinkDefault(
                    L10n.NetworkSettings.Gateway.title,
                    content: .constant(settings.localizedDefaultGateway)
                )
            }
            builder.routes4.map { routes in
                ForEach(routes, id: \.self) { route in
                    themeLongContentLinkDefault(
                        L10n.Endpoint.Advanced.Openvpn.Items.Route.caption,
                        content: .constant(route.localizedDescription)
                    )
                }
            }
        } header: {
            Text(Unlocalized.Network.ipv4)
        }
    }

    private var ipv6Section: some View {
        Section {
            if let settings = builder.ipv6 {
                themeLongContentLinkDefault(
                    L10n.Global.Strings.address,
                    content: .constant(settings.localizedAddress)
                )
                themeLongContentLinkDefault(
                    L10n.NetworkSettings.Gateway.title,
                    content: .constant(settings.localizedDefaultGateway)
                )
            }
            builder.routes6.map { routes in
                ForEach(routes, id: \.self) { route in
                    themeLongContentLinkDefault(
                        L10n.Endpoint.Advanced.Openvpn.Items.Route.caption,
                        content: .constant(route.localizedDescription)
                    )
                }
            }
        } header: {
            Text(Unlocalized.Network.ipv6)
        }
    }

    private func communicationSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.communicationSettings.map { settings in
            Section {
                settings.cipher.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.Cipher.caption)
                        .withTrailingText($0.localizedDescription)
                }
                settings.digest.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.Digest.caption)
                        .withTrailingText($0.localizedDescription)
                }
                if let xor = settings.xor {
                    themeLongContentLink(
                        Unlocalized.VPN.xor,
                        content: .constant(xor.localizedLongDescription),
                        withPreview: xor.localizedDescription
                    )
                } else {
                    Text(Unlocalized.VPN.xor)
                        .withTrailingText(L10n.Global.Strings.disabled)
                }
            } header: {
                Text(L10n.Endpoint.Advanced.Openvpn.Sections.Communication.header)
            }
        }
    }

    private var communicationEditableSection: some View {
        Section {
            themeTextPicker(
                L10n.Endpoint.Advanced.Openvpn.Items.Cipher.caption,
                selection: $builder.cipher ?? fallbackCipher,
                values: OpenVPN.Cipher.available,
                description: \.localizedDescription
            )
            themeTextPicker(
                L10n.Endpoint.Advanced.Openvpn.Items.Digest.caption,
                selection: $builder.digest ?? fallbackDigest,
                values: OpenVPN.Digest.available,
                description: \.localizedDescription
            )
            if let xor = builder.xorMethod {
                themeLongContentLink(
                    Unlocalized.VPN.xor,
                    content: .constant(xor.localizedLongDescription),
                    withPreview: xor.localizedDescription
                )
            } else {
                Text(Unlocalized.VPN.xor)
                    .withTrailingText(L10n.Global.Strings.disabled)
            }
        } header: {
            Text(L10n.Endpoint.Advanced.Openvpn.Sections.Communication.header)
        }
    }

    private func compressionSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.compressionSettings.map { settings in
            Section {
                settings.framing.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.CompressionFraming.caption)
                        .withTrailingText($0.localizedDescription)
                }
                settings.algorithm.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.CompressionAlgorithm.caption)
                        .withTrailingText($0.localizedDescription)
                }
            } header: {
                Text(L10n.Endpoint.Advanced.Openvpn.Sections.Compression.header)
            }
        }
    }

    private var compressionEditableSection: some View {
        Section {
            themeTextPicker(
                L10n.Endpoint.Advanced.Openvpn.Items.CompressionFraming.caption,
                selection: $builder.compressionFraming ?? fallbackCompressionFraming,
                values: OpenVPN.CompressionFraming.available,
                description: \.localizedDescription
            )
            themeTextPicker(
                L10n.Endpoint.Advanced.Openvpn.Items.CompressionAlgorithm.caption,
                selection: $builder.compressionAlgorithm ?? fallbackCompressionAlgorithm,
                values: OpenVPN.CompressionAlgorithm.available,
                description: \.localizedDescription
            ).disabled(builder.compressionFraming == .disabled)
        } header: {
            Text(L10n.Endpoint.Advanced.Openvpn.Sections.Compression.header)
        }
    }

    private func dnsSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.dnsSettings.map { settings in
            Section {
                ForEach(settings.servers, id: \.self) {
                    Text(L10n.Global.Strings.address)
                        .withTrailingText($0, copyOnTap: true)
                }
                ForEach(settings.domains, id: \.self) {
                    Text(L10n.Global.Strings.domain)
                        .withTrailingText($0, copyOnTap: true)
                }
            } header: {
                Text(Unlocalized.Network.dns)
            }
        }
    }

    private func proxySection(configuration: OpenVPN.Configuration) -> some View {
        configuration.proxySettings.map { settings in
            Section {
                settings.proxy.map {
                    Text(L10n.Global.Strings.address)
                        .withTrailingText($0.rawValue, copyOnTap: true)
                }
                settings.pac.map {
                    Text(Unlocalized.Network.proxyAutoConfiguration)
                        .withTrailingText($0.absoluteString, copyOnTap: true)
                }
                ForEach(settings.bypass, id: \.self) {
                    Text(L10n.NetworkSettings.Items.ProxyBypass.caption)
                        .withTrailingText($0, copyOnTap: true)
                }
            } header: {
                Text(L10n.Global.Strings.proxy)
            }
        }
    }

    private var tlsSection: some View {
        Section {
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
        } header: {
            Text(Unlocalized.Network.tls)
        }
    }

    private func otherSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.otherSettings.map { settings in
            Section {
                settings.keepAlive.map {
                    Text(L10n.Global.Strings.keepalive)
                        .withTrailingText($0.localizedDescriptionAsKeepAlive)
                }
                settings.reneg.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.RenegotiationSeconds.caption)
                        .withTrailingText($0.localizedDescriptionAsRenegotiatesAfter)
                }
                settings.randomizeEndpoint.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.RandomEndpoint.caption)
                        .withTrailingText($0.localizedDescriptionAsRandomizeEndpoint)
                }
                settings.randomizeHostnames.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.RandomHostname.caption)
                        .withTrailingText($0.localizedDescriptionAsRandomizeHostnames)
                }
            } header: {
                Text(L10n.Endpoint.Advanced.Openvpn.Sections.Other.header)
            }
        }
    }
}

private extension OpenVPN.Configuration {
    struct CommunicationOptions {
        let cipher: OpenVPN.Cipher?

        let digest: OpenVPN.Digest?

        let xor: OpenVPN.XORMethod?
    }

    struct CompressionOptions {
        let framing: OpenVPN.CompressionFraming?

        let algorithm: OpenVPN.CompressionAlgorithm?
    }

    struct DNSOptions {
        let servers: [String]

        let domains: [String]
    }

    struct ProxyOptions {
        let proxy: Proxy?

        let pac: URL?

        let bypass: [String]
    }

    struct OtherOptions {
        let keepAlive: TimeInterval?

        let reneg: TimeInterval?

        let randomizeEndpoint: Bool?

        let randomizeHostnames: Bool?
    }

    var communicationSettings: CommunicationOptions? {
        guard cipher != nil || digest != nil || xorMethod != nil else {
            return nil
        }
        return .init(cipher: cipher, digest: digest, xor: xorMethod)
    }

    var compressionSettings: CompressionOptions? {
        guard compressionFraming != nil || compressionAlgorithm != nil else {
            return nil
        }
        return .init(framing: compressionFraming, algorithm: compressionAlgorithm)
    }

    var dnsSettings: DNSOptions? {
        guard !(dnsServers?.isEmpty ?? true) || !(searchDomains?.isEmpty ?? true) else {
            return nil
        }
        return .init(servers: dnsServers ?? [], domains: searchDomains ?? [])
    }

    var proxySettings: ProxyOptions? {
        guard httpsProxy != nil || httpProxy != nil ||
                proxyAutoConfigurationURL != nil || !(proxyBypassDomains?.isEmpty ?? true) else {
            return nil
        }
        return .init(
            proxy: httpsProxy ?? httpProxy,
            pac: proxyAutoConfigurationURL,
            bypass: proxyBypassDomains ?? []
        )
    }

    var otherSettings: OtherOptions? {
        guard keepAliveInterval != nil || renegotiatesAfter != nil ||
                randomizeEndpoint != nil || randomizeHostnames != nil else {
            return nil
        }
        return .init(
            keepAlive: keepAliveInterval,
            reneg: renegotiatesAfter,
            randomizeEndpoint: randomizeEndpoint,
            randomizeHostnames: randomizeHostnames
        )
    }
}

private extension EndpointAdvancedView.OpenVPNView {
    var fallbackCipher: OpenVPN.Cipher {
        fallbackConfiguration.cipher!
    }

    var fallbackDigest: OpenVPN.Digest {
        fallbackConfiguration.digest!
    }

    var fallbackCompressionFraming: OpenVPN.CompressionFraming {
        fallbackConfiguration.compressionFraming!
    }

    var fallbackCompressionAlgorithm: OpenVPN.CompressionAlgorithm {
        fallbackConfiguration.compressionAlgorithm!
    }
}
