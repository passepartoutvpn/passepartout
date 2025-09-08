// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Partout

struct WireGuardImplementationBuilder: Sendable {
    func build() -> WireGuardModule.Implementation {
        WireGuardModule.Implementation(
            keyGenerator: StandardWireGuardKeyGenerator(),
            importer: StandardWireGuardParser(),
            validator: StandardWireGuardParser(),
            connectionBlock: {
                let preferences = $0.options.userInfo as? AppPreferenceValues
                let ctx = PartoutLoggerContext($0.profile.id)

                // Use new connection on manual preference or config flag
                if preferences?.usesModernCrypto == true ||
                    preferences?.configFlags.contains(.wgCrossConnection) == true {
                    pp_log_g(.app, .notice, "WireGuard: Using cross-platform connection")
                    return try WireGuardConnection(ctx, parameters: $0, module: $1)
                } else {
                    pp_log_g(.app, .notice, "WireGuard: Using legacy connection")
                    return try LegacyWireGuardConnection(ctx, parameters: $0, module: $1)
                }
            }
        )
    }
}
