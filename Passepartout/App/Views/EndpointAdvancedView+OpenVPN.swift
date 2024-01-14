//
//  EndpointAdvancedView+OpenVPN.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/8/22.
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

import PassepartoutLibrary
import SwiftUI
import TunnelKitOpenVPN

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

// MARK: -

private extension EndpointAdvancedView.OpenVPNView {
    func pullSection(configuration: OpenVPN.Configuration) -> some View {
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

    var ipv4Section: some View {
        Section {
            if let settings = builder.ipv4 {
                themeLongContentLinkDefault(
                    L10n.Global.Strings.address,
                    content: .constant(settings.localizedDescription(style: .address))
                )
                themeLongContentLinkDefault(
                    L10n.NetworkSettings.Gateway.title,
                    content: .constant(settings.localizedDescription(style: .defaultGateway))
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

    var ipv6Section: some View {
        Section {
            if let settings = builder.ipv6 {
                themeLongContentLinkDefault(
                    L10n.Global.Strings.address,
                    content: .constant(settings.localizedDescription(style: .address))
                )
                themeLongContentLinkDefault(
                    L10n.NetworkSettings.Gateway.title,
                    content: .constant(settings.localizedDescription(style: .defaultGateway))
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

    func communicationSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.communicationSettings.map { settings in
            Section {
                settings.cipher.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.Cipher.caption)
                        .withTrailingText($0)
                }
                settings.digest.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.Digest.caption)
                        .withTrailingText($0)
                }
                if let xor = settings.xor {
                    themeLongContentLink(
                        Unlocalized.VPN.xor,
                        content: .constant(xor.longDescription),
                        withPreview: xor.shortDescription
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

    var communicationEditableSection: some View {
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
                    content: .constant(xor.localizedDescription(style: .long)),
                    withPreview: xor.localizedDescription(style: .short)
                )
            } else {
                Text(Unlocalized.VPN.xor)
                    .withTrailingText(L10n.Global.Strings.disabled)
            }
        } header: {
            Text(L10n.Endpoint.Advanced.Openvpn.Sections.Communication.header)
        }
    }

    func compressionSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.compressionSettings.map { settings in
            Section {
                settings.framing.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.CompressionFraming.caption)
                        .withTrailingText($0)
                }
                settings.algorithm.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.CompressionAlgorithm.caption)
                        .withTrailingText($0)
                }
            } header: {
                Text(L10n.Endpoint.Advanced.Openvpn.Sections.Compression.header)
            }
        }
    }

    var compressionEditableSection: some View {
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

    func dnsSection(configuration: OpenVPN.Configuration) -> some View {
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

    func proxySection(configuration: OpenVPN.Configuration) -> some View {
        configuration.proxySettings.map { settings in
            Section {
                settings.proxy.map {
                    Text(L10n.Global.Strings.address)
                        .withTrailingText($0, copyOnTap: true)
                }
                settings.pac.map {
                    Text(Unlocalized.Network.proxyAutoConfiguration)
                        .withTrailingText($0, copyOnTap: true)
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

    var tlsSection: some View {
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
                    withPreview: builder.localizedDescription(style: .tlsWrap)
                )
            }
            Text(L10n.Endpoint.Advanced.Openvpn.Items.Eku.caption)
                .withTrailingText(builder.localizedDescription(style: .eku))
        } header: {
            Text(Unlocalized.Network.tls)
        }
    }

    func otherSection(configuration: OpenVPN.Configuration) -> some View {
        configuration.otherSettings.map { settings in
            Section {
                settings.keepAlive.map {
                    Text(L10n.Global.Strings.keepalive)
                        .withTrailingText($0)
                }
                settings.reneg.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.RenegotiationSeconds.caption)
                        .withTrailingText($0)
                }
                settings.randomizeEndpoint.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.RandomEndpoint.caption)
                        .withTrailingText($0)
                }
                settings.randomizeHostnames.map {
                    Text(L10n.Endpoint.Advanced.Openvpn.Items.RandomHostname.caption)
                        .withTrailingText($0)
                }
            } header: {
                Text(L10n.Endpoint.Advanced.Openvpn.Sections.Other.header)
            }
        }
    }
}

private extension OpenVPN.Configuration {
    struct CommunicationOptions {
        let cipher: String?

        let digest: String?

        let xor: (shortDescription: String, longDescription: String)?
    }

    struct CompressionOptions {
        let framing: String?

        let algorithm: String?
    }

    struct DNSOptions {
        let servers: [String]

        let domains: [String]
    }

    struct ProxyOptions {
        let proxy: String?

        let pac: String?

        let bypass: [String]
    }

    struct OtherOptions {
        let keepAlive: String?

        let reneg: String?

        let randomizeEndpoint: String?

        let randomizeHostnames: String?
    }

    var communicationSettings: CommunicationOptions? {
        guard cipher != nil || digest != nil || xorMethod != nil else {
            return nil
        }
        return .init(
            cipher: cipher?.localizedDescription,
            digest: digest?.localizedDescription,
            xor: xorMethod.map {
                ($0.localizedDescription(style: .short), $0.localizedDescription(style: .long))
            }
        )
    }

    var compressionSettings: CompressionOptions? {
        guard compressionFraming != nil || compressionAlgorithm != nil else {
            return nil
        }
        return .init(
            framing: compressionFraming?.localizedDescription,
            algorithm: compressionAlgorithm?.localizedDescription
        )
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
            proxy: (httpsProxy ?? httpProxy)?.rawValue,
            pac: proxyAutoConfigurationURL?.absoluteString,
            bypass: proxyBypassDomains ?? []
        )
    }

    var otherSettings: OtherOptions? {
        guard keepAliveInterval != nil || renegotiatesAfter != nil ||
                randomizeEndpoint != nil || randomizeHostnames != nil else {
            return nil
        }
        return .init(
            keepAlive: localizedDescription(optionalStyle: .keepAlive),
            reneg: localizedDescription(optionalStyle: .renegotiatesAfter),
            randomizeEndpoint: localizedDescription(optionalStyle: .randomizeEndpoint),
            randomizeHostnames: localizedDescription(optionalStyle: .randomizeHostnames)
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
