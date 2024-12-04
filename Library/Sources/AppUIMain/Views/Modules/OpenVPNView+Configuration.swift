//
//  OpenVPNView+Configuration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
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

extension OpenVPNView {
    struct ConfigurationView: View {
        let isServerPushed: Bool

        let configuration: OpenVPN.Configuration.Builder

        let credentialsRoute: (any Hashable)?

        var body: some View {
            moduleSection(for: accountRows, header: Strings.Global.Nouns.account)
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
            moduleSection(for: otherRows, header: Strings.Global.Nouns.other)
        }
    }
}

private extension OpenVPNView.ConfigurationView {
    var accountRows: [ModuleRow]? {
        guard let credentialsRoute else {
            return nil
        }
        guard configuration.authUserPass == true else {
            return nil
        }
        return [.push(
            caption: Strings.Modules.Openvpn.credentials,
            route: HashableRoute(credentialsRoute))
        ]
    }

    var remotesRows: [ModuleRow]? {
        configuration.remotes?.map {
            .copiableText(
                value: "\($0.address.rawValue) → \($0.proto.socketType.rawValue):\($0.proto.port)"
            )
        }
        .nilIfEmpty
    }

    var pullRows: [ModuleRow]? {
        configuration.pullMask?.map {
            .text(caption: $0.localizedDescription, value: nil)
        }
        .nilIfEmpty
    }

    func ipRows(for ip: IPSettings?, routes: [Route]?) -> [ModuleRow]? {
        var rows: [ModuleRow] = []
        if let ip {
            ip.localizedDescription(optionalStyle: .address).map {
                rows.append(.copiableText(caption: Strings.Global.Nouns.address, value: $0))
            }
            ip.localizedDescription(optionalStyle: .defaultGateway).map {
                rows.append(.copiableText(caption: Strings.Global.Nouns.gateway, value: $0))
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
            rows.append(.longContent(caption: Strings.Global.Nouns.route, value: $0.localizedDescription))
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
                    caption: Strings.Global.Nouns.servers,
                    values: $0
                ))
            }

        configuration.dnsDomain.map {
            rows.append(.copiableText(
                caption: Strings.Global.Nouns.domain,
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
            rows.append(.longContentPreview(caption: Strings.Global.Nouns.certificate, value: $0.pem, preview: nil))
        }
        configuration.clientKey.map {
            rows.append(.longContentPreview(caption: Strings.Global.Nouns.key, value: $0.pem, preview: nil))
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
            rows.append(.text(caption: Strings.Global.Nouns.keepAlive, value: $0))
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
