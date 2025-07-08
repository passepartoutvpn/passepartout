//
//  OpenVPNImplementationBuilder.swift
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
import Foundation
import Partout
import PartoutOpenVPN

struct OpenVPNImplementationBuilder: Sendable {
    private let distributionTarget: DistributionTarget

    private let usesExperimentalCrypto: @Sendable () -> Bool

    init(
        distributionTarget: DistributionTarget,
        usesExperimentalCrypto: @escaping @Sendable () -> Bool
    ) {
        self.distributionTarget = distributionTarget
        self.usesExperimentalCrypto = usesExperimentalCrypto
    }

    func build() -> OpenVPNModule.Implementation {
        OpenVPNModule.Implementation(
            importer: StandardOpenVPNParser(),
            connectionBlock: {
                if usesExperimentalCrypto() {
                    return try await crossConnection(with: $0, module: $1)
                } else {
                    return try await legacyConnection(with: $0, module: $1)
                }
            }
        )
    }
}

private extension OpenVPNImplementationBuilder {

    // TODO: #218, this directory must be per-profile
    var cachesURL: URL {
        FileManager.default.temporaryDirectory
    }

    func legacyConnection(
        with parameters: ConnectionParameters,
        module: OpenVPNModule
    ) async throws -> Connection {
        let ctx = PartoutLoggerContext(parameters.controller.profile.id)
        var options = OpenVPN.ConnectionOptions()
        options.writeTimeout = TimeInterval(parameters.options.linkWriteTimeout) / 1000.0
        options.minDataCountInterval = TimeInterval(parameters.options.minDataCountInterval) / 1000.0
        return try await OpenVPNConnection(
            ctx,
            parameters: parameters,
            module: module,
            prng: PlatformPRNG(),
            dns: SimpleDNSResolver {
                if distributionTarget.usesExperimentalPOSIXResolver {
                    return POSIXDNSStrategy(hostname: $0)
                } else {
                    return CFDNSStrategy(hostname: $0)
                }
            },
            options: options,
            cachesURL: cachesURL
        )
    }

    func crossConnection(
        with parameters: ConnectionParameters,
        module: OpenVPNModule
    ) async throws -> Connection {
        let ctx = PartoutLoggerContext(parameters.controller.profile.id)
        var options = OpenVPN.ConnectionOptions()
        options.writeTimeout = TimeInterval(parameters.options.linkWriteTimeout) / 1000.0
        options.minDataCountInterval = TimeInterval(parameters.options.minDataCountInterval) / 1000.0
        return try await CrossOpenVPNConnection(
            ctx,
            parameters: parameters,
            module: module,
            cachesURL: cachesURL,
            options: options
        )
    }
}
