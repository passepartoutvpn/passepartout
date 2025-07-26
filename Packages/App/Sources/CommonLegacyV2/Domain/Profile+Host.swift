// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

extension ProfileV2 {
    struct Host: Codable, Equatable {
        var ovpnSettings: OpenVPNSettings?

        var wgSettings: WireGuardSettings?
    }
}
