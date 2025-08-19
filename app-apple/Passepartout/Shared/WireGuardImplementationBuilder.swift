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
                let ctx = PartoutLoggerContext($0.controller.profile.id)
                return try WireGuardConnection(
                    ctx,
                    parameters: $0,
                    module: $1
                )
            }
        )
    }
}
