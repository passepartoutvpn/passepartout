// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation
import Partout

struct OpenVPNImplementationBuilder: Sendable {
    private let distributionTarget: DistributionTarget

    init(distributionTarget: DistributionTarget) {
        self.distributionTarget = distributionTarget
    }

    func build() -> OpenVPNModule.Implementation {
        OpenVPNModule.Implementation(
            importer: StandardOpenVPNParser(),
            connectionBlock: {
                let preferences = $0.options.userInfo as? AppPreferenceValues
                if preferences?.isFlagEnabled(.ovpnCrossConnection) == true {
                    pp_log_g(.app, .notice, "OpenVPN: Using cross-platform connection")
                    return try crossConnection(with: $0, module: $1)
                } else {
                    pp_log_g(.app, .notice, "OpenVPN: Using legacy connection")
                    return try legacyConnection(with: $0, module: $1)
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
    ) throws -> Connection {
        let ctx = PartoutLoggerContext(parameters.profile.id)
        var options = OpenVPN.ConnectionOptions()
        options.writeTimeout = TimeInterval(parameters.options.linkWriteTimeout) / 1000.0
        options.minDataCountInterval = TimeInterval(parameters.options.minDataCountInterval) / 1000.0
        return try LegacyOpenVPNConnection(
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
    ) throws -> Connection {
        let ctx = PartoutLoggerContext(parameters.profile.id)
        var options = OpenVPN.ConnectionOptions()
        options.writeTimeout = TimeInterval(parameters.options.linkWriteTimeout) / 1000.0
        options.minDataCountInterval = TimeInterval(parameters.options.minDataCountInterval) / 1000.0
        return try OpenVPNConnection(
            ctx,
            parameters: parameters,
            module: module,
            cachesURL: cachesURL,
            options: options
        )
    }
}
