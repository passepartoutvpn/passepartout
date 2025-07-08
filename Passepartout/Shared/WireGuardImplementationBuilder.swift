//
//  WireGuardImplementationBuilder.swift
//  Partout
//
//  Created by Davide De Rosa on 7/8/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//

import CommonLibrary
import Partout
import PartoutWireGuard

struct WireGuardImplementationBuilder: Sendable {
    private let usesExperimentalCrypto: @Sendable () -> Bool

    init(
        usesExperimentalCrypto: @escaping @Sendable () -> Bool
    ) {
        self.usesExperimentalCrypto = usesExperimentalCrypto
    }

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
