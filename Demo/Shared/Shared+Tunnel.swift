//
//  Shared+Tunnel.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 3/26/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import PassepartoutKit
import PassepartoutOpenVPNOpenSSL
import PassepartoutWireGuardGo

// MARK: - Implementations

extension Registry {
    static let shared = Registry(
        withKnownHandlers: true,
        allImplementations: [
            OpenVPNModule.Implementation(
                importer: StandardOpenVPNParser(),
                connectionBlock: {
                    try await OpenVPNConnection(
                        parameters: $0,
                        module: $1,
                        cachesURL: Demo.moduleURL(for: "OpenVPN")
                    )
                }
            ),
            WireGuardModule.Implementation(
                keyGenerator: StandardWireGuardKeyGenerator(),
                importer: StandardWireGuardParser(),
                connectionBlock: {
                    try WireGuardConnection(
                        parameters: $0,
                        module: $1
                    )
                }
            )
        ]
    )
}

extension NEProtocolDecoder where Self == KeychainNEProtocolCoder {
    static var shared: Self {
        Demo.neProtocolCoder
    }
}
