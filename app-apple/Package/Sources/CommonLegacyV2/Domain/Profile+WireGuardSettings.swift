// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation
import Partout
// FIXME: #93/partout, only import interfaces after moving WireGuard parser to Core
//import PartoutInterfaces

extension ProfileV2 {
    struct WireGuardSettings: Codable, Equatable, VPNProtocolProviding {
        struct WrappedConfiguration: Codable, Equatable {
            let configuration: WireGuard.Configuration

            init(configuration: WireGuard.Configuration) {
                self.configuration = configuration
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let wg = try container.decode(String.self)
                configuration = try StandardWireGuardParser().configuration(from: wg)
            }

            public func encode(to encoder: Encoder) throws {
                let wg = try StandardWireGuardParser().string(from: configuration)
                var container = encoder.singleValueContainer()
                try container.encode(wg)
            }
        }

        var vpnProtocol: VPNProtocolType {
            .wireGuard
        }

        var configuration: WrappedConfiguration

        init(configuration: WireGuard.Configuration) {
            self.configuration = WrappedConfiguration(configuration: configuration)
        }

    }

    init(_ id: UUID = UUID(), name: String, configuration: WireGuard.Configuration) {
        let header = Header(
            uuid: id,
            name: name,
            providerName: nil
        )
        self.init(header, configuration: configuration)
    }

    init(_ header: Header, configuration: WireGuard.Configuration) {
        self.header = header
        currentVPNProtocol = .wireGuard
        host = Host()
        host?.wgSettings = WireGuardSettings(configuration: configuration)
    }
}
