// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

extension ProfileV2 {
    struct OpenVPNSettings: Codable, Equatable, VPNProtocolProviding {
        var vpnProtocol: VPNProtocolType {
            .openVPN
        }

        var configuration: OpenVPN.Configuration

        var account: Account?

        var customEndpoint: Endpoint?

        init(configuration: OpenVPN.Configuration) {
            self.configuration = configuration
        }
    }

    init(_ id: UUID = UUID(), name: String, configuration: OpenVPN.Configuration) {
        let header = Header(
            uuid: id,
            name: name,
            providerName: nil
        )
        self.init(header, configuration: configuration)
    }

    init(_ header: Header, configuration: OpenVPN.Configuration) {
        self.header = header
        currentVPNProtocol = .openVPN
        host = Host()
        host?.ovpnSettings = OpenVPNSettings(configuration: configuration)
    }
}
