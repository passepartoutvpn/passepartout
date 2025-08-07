// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

typealias ProviderName = String

extension ProfileV2 {
    struct Provider: Codable, Equatable {
        struct Settings: Codable, Equatable {
            var account: Account?

            var serverId: String?

            var presetId: String?

            var favoriteLocationIds: Set<String>?

            var customEndpoint: Endpoint?

            init() {
            }
        }

        let name: ProviderName

        var vpnSettings: [VPNProtocolType: Settings] = [:]

        var randomizesServer: Bool?

        init(_ name: ProviderName) {
            self.name = name
        }
   }
}
