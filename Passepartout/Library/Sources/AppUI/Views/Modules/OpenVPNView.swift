//
//  OpenVPNView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

extension OpenVPNModule.Builder: ModuleViewProviding {
    func moduleView(with editor: ProfileEditor) -> some View {
        OpenVPNView(editor: editor, original: self)
    }
}

extension OpenVPNModule.Builder: InteractiveViewProviding {
    func interactiveView(with editor: ProfileEditor) -> some View {
        let draft = editor.binding(forModule: self)

        return OpenVPNView.CredentialsView(
            isInteractive: draft.isInteractive,
            credentials: draft.credentials,
            isAuthenticating: true
        )
    }
}

struct OpenVPNView: View {
    private enum Subroute: Hashable {
        case credentials
    }

    @ObservedObject
    private var editor: ProfileEditor

    private let isServerPushed: Bool

    @Binding
    private var draft: OpenVPNModule.Builder

    init(serverConfiguration: OpenVPN.Configuration) {
        let module = OpenVPNModule.Builder(configurationBuilder: serverConfiguration.builder())
        editor = ProfileEditor(modules: [module])
        _draft = .constant(module)
        isServerPushed = true
    }

    init(editor: ProfileEditor, original: OpenVPNModule.Builder) {
        self.editor = editor
        _draft = editor.binding(forModule: original)
        isServerPushed = false
    }

    var body: some View {
        Group {
            moduleSection(for: accountRows, header: Strings.Global.account)
            moduleSection(for: remotesRows, header: Strings.Modules.Openvpn.remotes)
            if !isServerPushed {
                moduleSection(for: pullRows, header: Strings.Modules.Openvpn.pull)
            }
            moduleSection(for: redirectRows, header: Strings.Modules.Openvpn.redirectGateway)
            moduleSection(
                for: ipRows(for: configuration.ipv4, routes: configuration.routes4),
                header: Strings.Unlocalized.ipv4
            )
            moduleSection(
                for: ipRows(for: configuration.ipv6, routes: configuration.routes6),
                header: Strings.Unlocalized.ipv6
            )
            moduleSection(for: dnsRows, header: Strings.Unlocalized.dns)
            moduleSection(for: proxyRows, header: Strings.Unlocalized.proxy)
            moduleSection(for: communicationRows, header: Strings.Modules.Openvpn.communication)
            moduleSection(for: compressionRows, header: Strings.Modules.Openvpn.compression)
            if !isServerPushed {
                moduleSection(for: tlsRows, header: Strings.Unlocalized.tls)
            }
            moduleSection(for: otherRows, header: Strings.Global.other)
        }
        .asModuleView(with: editor, draft: draft, withName: !isServerPushed)
        .navigationDestination(for: Subroute.self) { route in
            switch route {
            case .credentials:
                CredentialsView(
                    isInteractive: $draft.isInteractive,
                    credentials: $draft.credentials
                )
            }
        }
    }
}

private extension OpenVPNView {
    var configuration: OpenVPN.Configuration.Builder {
        draft.configurationBuilder
    }

    var pullRows: [ModuleRow]? {
        configuration.pullMask?.map {
            .text(caption: $0.localizedDescription, value: nil)
        }
        .nilIfEmpty
    }

    var accountRows: [ModuleRow]? {
        guard configuration.authUserPass == true else {
            return nil
        }
        return [.push(caption: Strings.Modules.Openvpn.credentials, route: HashableRoute(Subroute.credentials))]
    }

    var remotesRows: [ModuleRow]? {
        configuration.remotes?.map {
            .copiableText(
                value: "\($0.address.rawValue) → \($0.proto.socketType.rawValue):\($0.proto.port)"
            )
        }
        .nilIfEmpty
    }

    func ipRows(for ip: IPSettings?, routes: [Route]?) -> [ModuleRow]? {
        var rows: [ModuleRow] = []
        if let ip {
            ip.localizedDescription(optionalStyle: .address).map {
                rows.append(.copiableText(caption: Strings.Global.address, value: $0))
            }
            ip.localizedDescription(optionalStyle: .defaultGateway).map {
                rows.append(.copiableText(caption: Strings.Global.gateway, value: $0))
            }

            ip.includedRoutes
                .filter { !$0.isDefault }
                .nilIfEmpty
                .map {
                    rows.append(.textList(
                        caption: Strings.Modules.Ip.Routes.included,
                        values: $0.map(\.localizedDescription)
                    ))
                }

            ip.excludedRoutes
                .nilIfEmpty
                .map {
                    rows.append(.textList(
                        caption: Strings.Modules.Ip.Routes.excluded,
                        values: $0.map(\.localizedDescription)
                    ))
                }
        }
        routes?.forEach {
            rows.append(.longContent(caption: Strings.Global.route, value: $0.localizedDescription))
        }
        return rows.nilIfEmpty
    }

    var redirectRows: [ModuleRow]? {
        configuration.routingPolicies?
            .compactMap {
                switch $0 {
                case .IPv4:
                    return .text(caption: Strings.Unlocalized.ipv4)

                case .IPv6:
                    return .text(caption: Strings.Unlocalized.ipv6)

                default:
                    return nil
                }
            }
            .nilIfEmpty
    }

    var dnsRows: [ModuleRow]? {
        var rows: [ModuleRow] = []

        configuration.dnsServers?
            .nilIfEmpty
            .map {
                rows.append(.textList(
                    caption: Strings.Global.servers,
                    values: $0
                ))
            }

        configuration.dnsDomain.map {
            rows.append(.copiableText(
                caption: Strings.Global.domain,
                value: $0
            ))
        }

        configuration.searchDomains?
            .nilIfEmpty
            .map {
                rows.append(.textList(
                    caption: Strings.Entities.Dns.searchDomains,
                    values: $0
                ))
            }

        return rows.nilIfEmpty
    }

    var proxyRows: [ModuleRow]? {
        var rows: [ModuleRow] = []
        configuration.httpProxy.map {
            rows.append(.copiableText(
                caption: Strings.Unlocalized.http,
                value: $0.rawValue
            ))
        }
        configuration.httpsProxy.map {
            rows.append(.copiableText(
                caption: Strings.Unlocalized.https,
                value: $0.rawValue
            ))
        }
        configuration.proxyAutoConfigurationURL.map {
            rows.append(.copiableText(
                caption: Strings.Unlocalized.pac,
                value: $0.absoluteString
            ))
        }
        configuration.proxyBypassDomains?
            .nilIfEmpty
            .map {
                rows.append(.textList(
                    caption: Strings.Entities.HttpProxy.bypassDomains,
                    values: $0
                ))
            }
        return rows.nilIfEmpty
    }

    var communicationRows: [ModuleRow]? {
        var rows: [ModuleRow] = []
        configuration.cipher.map {
            rows.append(.text(caption: Strings.Modules.Openvpn.cipher, value: $0.localizedDescription))
        }
        configuration.digest.map {
            rows.append(.text(caption: Strings.Modules.Openvpn.digest, value: $0.localizedDescription))
        }
        if let xorMethod = configuration.xorMethod {
            rows.append(.longContentPreview(
                caption: Strings.Unlocalized.xor,
                value: xorMethod.localizedDescription(style: .long),
                preview: xorMethod.localizedDescription(style: .short)
            ))
        }
        return rows.nilIfEmpty
    }

    var compressionRows: [ModuleRow]? {
        var rows: [ModuleRow] = []
        configuration.compressionFraming.map {
            rows.append(.text(caption: Strings.Modules.Openvpn.compressionFraming, value: $0.localizedDescription))
        }
        configuration.compressionAlgorithm.map {
            rows.append(.text(caption: Strings.Modules.Openvpn.compressionAlgorithm, value: $0.localizedDescription))
        }
        return rows.nilIfEmpty
    }

    var tlsRows: [ModuleRow]? {
        var rows: [ModuleRow] = []
        configuration.ca.map {
            rows.append(.longContentPreview(caption: Strings.Unlocalized.ca, value: $0.pem, preview: nil))
        }
        configuration.clientCertificate.map {
            rows.append(.longContentPreview(caption: Strings.Global.certificate, value: $0.pem, preview: nil))
        }
        configuration.clientKey.map {
            rows.append(.longContentPreview(caption: Strings.Global.key, value: $0.pem, preview: nil))
        }
        configuration.tlsWrap.map {
            rows.append(.longContentPreview(
                caption: Strings.Modules.Openvpn.tlsWrap,
                value: $0.key.hexString,
                preview: configuration.localizedDescription(style: .tlsWrap)
            ))
        }
        rows.append(.text(caption: Strings.Modules.Openvpn.eku, value: configuration.localizedDescription(style: .eku)))
        return rows.nilIfEmpty
    }

    var otherRows: [ModuleRow]? {
        var rows: [ModuleRow] = []
        configuration.localizedDescription(optionalStyle: .keepAlive).map {
            rows.append(.text(caption: Strings.Global.keepAlive, value: $0))
        }
        configuration.localizedDescription(optionalStyle: .renegotiatesAfter).map {
            rows.append(.text(caption: Strings.Modules.Openvpn.renegotiation, value: $0))
        }
        configuration.localizedDescription(optionalStyle: .randomizeEndpoint).map {
            rows.append(.text(caption: Strings.Modules.Openvpn.randomizeEndpoint, value: $0))
        }
        configuration.localizedDescription(optionalStyle: .randomizeHostnames).map {
            rows.append(.text(caption: Strings.Modules.Openvpn.randomizeHostname, value: $0))
        }
        return rows.nilIfEmpty
    }
}

private extension OpenVPNView {
    func importConfiguration(from url: URL) {
        // TODO: #657, import draft from external URL
    }
}

// MARK: - Previews

// swiftlint: disable force_try
#Preview {
    var builder = OpenVPN.Configuration.Builder(withFallbacks: true)
    builder.noPullMask = [.proxy]
    builder.authUserPass = true
    builder.remotes = [
        .init(rawValue: "2.2.2.2:UDP:2222")!,
        .init(rawValue: "6.6.6.6:UDP:6666")!,
        .init(rawValue: "12.12.12.12:TCP:21212")!,
        .init(rawValue: "12:12:12:12:20:20:20:20:TCP6:21212")!
    ]
    builder.ipv4 = IPSettings(subnet: try! .init("5.5.5.5", 24))
        .including(routes: [
            .init(defaultWithGateway: .ip("120.1.1.1", .v4)),
            .init(.init(rawValue: "55.10.20.30/32"), nil)
        ])
        .excluding(routes: [
            .init(.init(rawValue: "88.40.30.30/32"), nil),
            .init(.init(rawValue: "60.60.60.60/32"), .ip("127.0.0.1", .v4))
        ])
    builder.ipv6 = IPSettings(subnet: try! .init("::5", 24))
        .including(routes: [
            .init(defaultWithGateway: .ip("120::1:1:1", .v6)),
            .init(.init(rawValue: "55:10:20::30/128"), nil),
            .init(.init(rawValue: "60:60:60::60/128"), .ip("::2", .v6))
        ])
        .excluding(routes: [
            .init(.init(rawValue: "88:40:30::30/32"), nil)
        ])
    builder.routingPolicies = [.IPv4, .IPv6]
    builder.dnsServers = ["1.2.3.4", "4.5.6.7"]
    builder.dnsDomain = "domain.com"
    builder.searchDomains = ["search1.com", "search2.com"]
    builder.httpProxy = try! .init("10.10.10.10", 1080)
    builder.httpsProxy = try! .init("10.10.10.10", 8080)
    builder.proxyAutoConfigurationURL = URL(string: "https://hello.pac")!
    builder.proxyBypassDomains = ["bypass1.com", "bypass2.com"]
    builder.xorMethod = .xormask(mask: .init(Data(hex: "1234")))
    builder.ca = .init(mockPem: "ca-certificate")
    builder.clientCertificate = .init(mockPem: "client-certificate")
    builder.clientKey = .init(mockPem: "client-key")
    builder.tlsWrap = .init(strategy: .auth, key: .init(biData: Data(count: 256)))
    builder.keepAliveInterval = 10.0
    builder.renegotiatesAfter = 60.0
    builder.randomizeEndpoint = true
    builder.randomizeHostnames = true

    let module = OpenVPNModule.Builder(configurationBuilder: builder)
    return module.preview(title: "OpenVPN")
}
// swiftlint: enable force_try

private extension OpenVPN.CryptoContainer {
    init(mockPem: String) {
        self.init(pem: """
-----BEGIN CERTIFICATE-----
\(mockPem)
-----END CERTIFICATE-----
""")
    }
}
