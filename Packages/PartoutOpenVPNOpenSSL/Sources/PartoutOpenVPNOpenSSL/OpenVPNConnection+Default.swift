//
//  OpenVPNConnection+Default.swift
//  Partout
//
//  Created by Davide De Rosa on 1/10/25.
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

internal import CPartoutOpenVPNOpenSSL
import Foundation
import Partout

extension OpenVPNConnection {
    public init(
        parameters: ConnectionParameters,
        module: OpenVPNModule,
        options: OpenVPN.ConnectionOptions = .init(),
        cachesURL: URL
    ) async throws {
        guard let configuration = module.configuration else {
            fatalError("Creating session without OpenVPN configuration?")
        }
        let prng = SecureRandom()
        let dns = SimpleDNSResolver {
            CFDNSStrategy(hostname: $0)
        }
        let tlsFactory = { @Sendable in
            OSSLTLSBox()
        }
        let cryptoFactory = { @Sendable in
            let seed = prng.safeData(length: 64)
            guard let box = OSSLCryptoBox(seed: seed) else {
                fatalError("Unable to create OSSLCryptoBox")
            }
            return box
        }

        let session = try await OpenVPNSession(
            configuration: configuration,
            credentials: module.credentials,
            prng: prng,
            tlsFactory: tlsFactory,
            cryptoFactory: cryptoFactory,
            cachesURL: cachesURL,
            options: options
        )

        try await self.init(
            parameters: parameters,
            module: module,
            prng: prng,
            dns: dns,
            session: session
        )
    }
}
