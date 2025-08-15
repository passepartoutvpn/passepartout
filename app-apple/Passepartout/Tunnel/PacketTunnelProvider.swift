//
//  PacketTunnelProvider.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/24/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
@preconcurrency import NetworkExtension

// FIXME: #1369, refactor to handle PTP started multiple times (macOS, desktop)
// FIXME: #1369, diagnostics/logs must be per-tunnel (optional Profile.ID in pp_log?)

final class PacketTunnelProvider: NEPacketTunnelProvider, @unchecked Sendable {

    @MainActor
    private let context: TunnelContext = .shared

    @MainActor
    private let dependencies: Dependencies = .shared

    private var fwd: NEPTPForwarder?

    private var verifierSubscription: Task<Void, Error>?

    override func startTunnel(options: [String: NSObject]? = nil) async throws {
        await CommonLibrary(kvStore: context.kvStore)
            .configure(.tunnel)

        pp_log(.app, .info, "Tunnel started with options: \(options?.description ?? "nil")")

        do {
            fwd = try await NEPTPForwarder(
                provider: self,
                decoder: dependencies.neProtocolCoder(),
                registry: dependencies.registry,
                environmentFactory: {
                    self.dependencies.tunnelEnvironment(profileId: $0)
                },
                willProcess: context.processor.willProcess
            )
            guard let fwd else {
                fatalError("NEPTPForwarder nil without throwing error?")
            }

            let environment = fwd.environment

            // check hold flag
            if environment.environmentValue(forKey: TunnelEnvironmentKeys.holdFlag) == true {
                pp_log(.app, .info, "Tunnel is on hold")
                guard options?[ExtendedTunnel.isManualKey] == true as NSNumber else {
                    pp_log(.app, .error, "Tunnel was started non-interactively, hang here")
                    return
                }
                pp_log(.app, .info, "Tunnel was started interactively, clear hold flag")
                environment.removeEnvironmentValue(forKey: TunnelEnvironmentKeys.holdFlag)
            }

            // prepare for receipt verification
            await context.iapManager.fetchLevelIfNeeded()
            let params = await Constants.shared.tunnel.verificationParameters(isBeta: context.iapManager.isBeta)
            pp_log(.app, .info, "Will start profile verification in \(params.delay) seconds")

            // start tunnel
            try await fwd.startTunnel(options: options)

            // #1070, do not wait for this to start the tunnel. if on-demand is
            // enabled, networking will stall and StoreKit network calls may
            // produce a deadlock
            verifierSubscription = Task { [weak self] in
                guard let self else {
                    return
                }
                try await Task.sleep(for: .seconds(params.delay))
                guard !Task.isCancelled else {
                    return
                }
                await verifyEligibility(
                    of: fwd.originalProfile,
                    environment: environment,
                    params: params
                )
            }
        } catch {
            pp_log(.app, .fault, "Unable to start tunnel: \(error)")
            PartoutConfiguration.shared.flushLog()
            throw error
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason) async {
        verifierSubscription?.cancel()
        await fwd?.stopTunnel(with: reason)
        fwd = nil
        PartoutConfiguration.shared.flushLog()
    }

    override func cancelTunnelWithError(_ error: (any Error)?) {
        PartoutConfiguration.shared.flushLog()
        super.cancelTunnelWithError(error)
    }

    override func handleAppMessage(_ messageData: Data) async -> Data? {
        await fwd?.handleAppMessage(messageData)
    }

    override func wake() {
        fwd?.wake()
    }

    override func sleep() async {
        await fwd?.sleep()
    }
}

// MARK: - Eligibility

private extension PacketTunnelProvider {

    @MainActor
    func verifyEligibility(
        of profile: Profile,
        environment: TunnelEnvironment,
        params: Constants.Tunnel.Verification.Parameters
    ) async {
        var attempts = params.attempts

        while true {
            do {
                pp_log(.app, .info, "Verify profile, requires: \(profile.features)")
                await context.iapManager.reloadReceipt()
                try context.iapManager.verify(profile)
            } catch {

                // mitigate the StoreKit inability to report errors, sometimes it
                // would just return empty products, e.g. on network failure. in those
                // cases, retry a few times before failing
                if attempts > 0 {
                    attempts -= 1
                    pp_log(.app, .error, "Verification failed for profile \(profile.id), next attempt in \(params.retryInterval) seconds... (remaining: \(attempts), products: \(context.iapManager.purchasedProducts))")
                    try? await Task.sleep(interval: params.retryInterval)
                    continue
                }

                let error = PartoutError(.App.ineligibleProfile)
                environment.setEnvironmentValue(error.code, forKey: TunnelEnvironmentKeys.lastErrorCode)
                pp_log(.app, .fault, "Verification failed for profile \(profile.id), shutting down: \(error)")

                // prevent on-demand reconnection
                environment.setEnvironmentValue(true, forKey: TunnelEnvironmentKeys.holdFlag)
                await fwd?.holdTunnel()
                return
            }

            pp_log(.app, .info, "Will verify profile again in \(params.interval) seconds...")
            try? await Task.sleep(interval: params.interval)

            // reset attempts for next verification
            attempts = params.attempts
        }
    }
}

private extension TunnelEnvironmentKeys {
    static let holdFlag = TunnelEnvironmentKey<Bool>("Tunnel.onHold")
}
