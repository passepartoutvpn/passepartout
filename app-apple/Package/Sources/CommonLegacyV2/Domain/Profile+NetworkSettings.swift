// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

extension ProfileV2 {
    struct NetworkSettings: Codable, Equatable {
        var gateway: Network.GatewaySettings

        var dns: Network.DNSSettings

        var proxy: Network.ProxySettings

        var mtu: Network.MTUSettings

        var resolvesHostname = true

        var keepsAliveOnSleep = true

        init(choice: Network.Choice) {
            gateway = Network.GatewaySettings(choice: choice)
            dns = Network.DNSSettings(choice: choice)
            proxy = Network.ProxySettings(choice: choice)
            mtu = Network.MTUSettings(choice: choice)
        }

        init() {
            self.init(choice: .defaultChoice)
        }
    }
}
