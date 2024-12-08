//
//  Dependencies+PassepartoutKit.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/2/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import CPassepartoutOpenVPNOpenSSL
import Foundation
import PassepartoutKit
import PassepartoutWireGuardGo

extension Dependencies {
    var registry: Registry {
        Self.sharedRegistry
    }

    func neProtocolCoder() -> NEProtocolCoder {
        KeychainNEProtocolCoder(
            tunnelBundleIdentifier: BundleConfiguration.mainString(for: .tunnelId),
            registry: registry,
            coder: CodableProfileCoder(),
            keychain: AppleKeychain(group: BundleConfiguration.mainString(for: .keychainGroupId))
        )
    }

    func tunnelEnvironment() -> TunnelEnvironment {
        AppGroupEnvironment(
            appGroup: BundleConfiguration.mainString(for: .groupId),
            prefix: "PassepartoutKit."
        )
    }
}

private extension Dependencies {
    static let sharedRegistry = Registry(
        withKnownHandlers: true,
        allImplementations: [
            OpenVPNModule.Implementation(
                prng: SecureRandom(),
                dns: SimpleDNSResolver {
                    CFDNSStrategy(hostname: $0)
                },
                importer: StandardOpenVPNParser(decrypter: OSSLTLSBox()),
                sessionBlock: { _, module in
                    guard let configuration = module.configuration else {
                        fatalError("Creating session without OpenVPN configuration?")
                    }
                    return try OpenVPNSession(
                        configuration: configuration,
                        credentials: module.credentials,
                        prng: SecureRandom(),
                        tlsFactory: {
                            OSSLTLSBox()
                        },
                        cryptoFactory: {
                            OSSLCryptoBox()
                        },
                        cachesURL: FileManager.default.temporaryDirectory
                    )
                }
            ),
            WireGuardModule.Implementation(
                keyGenerator: StandardWireGuardKeyGenerator(),
                importer: StandardWireGuardParser(),
                connectionBlock: { parameters, module in
                    try GoWireGuardConnection(parameters: parameters, module: module)
                }
            )
        ]
    )
}
