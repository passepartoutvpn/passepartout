// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

extension ProfileV2 {
    struct OnDemand: Codable, Equatable {
        enum Policy: String, Codable {
            case any

            case including

            case excluding // "trusted networks"
        }

        enum OtherNetwork: String, Codable {
            case mobile

            case ethernet
        }

        var isEnabled = true

        var policy: Policy = .excluding

        var withSSIDs: [String: Bool] = [:]

        var withOtherNetworks: Set<OtherNetwork> = []
    }
}
