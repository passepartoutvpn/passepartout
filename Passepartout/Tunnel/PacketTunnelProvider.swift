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

// FIXME: #1369, prevent PTP from starting multiple times (macOS, desktop)
// FIXME: #1373, diagnostics/logs must be per-tunnel

final class PacketTunnelProvider: NEPacketTunnelProvider, @unchecked Sendable {
    private var tunnelContext: TunnelContext?

    private var ctx: PartoutContext?

    private var fwd: NEPTPForwarder?

    private var verifierSubscription: Task<Void, Error>?

    override func startTunnel(options: [String: NSObject]? = nil) async throws {
        pp_log_g(.app, .info, "Tunnel started with options: \(options?.description ?? "nil")")

        let tunnelContext = try await TunnelContext(with: .shared, provider: self)
        let ctx = tunnelContext.partoutContext
        self.ctx = ctx

        do {
            fwd = try await NEPTPForwarder(ctx, controller: tunnelContext.neTunnelController)
            guard let fwd else {
                fatalError("NEPTPForwarder nil without throwing error?")
            }

            let environment = fwd.environment

            // check hold flag
            if environment.environmentValue(forKey: TunnelEnvironmentKeys.holdFlag) == true {
                pp_log(ctx, .app, .info, "Tunnel is on hold")
                guard options?[ExtendedTunnel.isManualKey] == true as NSNumber else {
                    pp_log(ctx, .app, .error, "Tunnel was started non-interactively, hang here")
                    return
                }
                pp_log(ctx, .app, .info, "Tunnel was started interactively, clear hold flag")
                environment.removeEnvironmentValue(forKey: TunnelEnvironmentKeys.holdFlag)
            }

            // prepare for receipt verification
            await tunnelContext.iapManager.fetchLevelIfNeeded()
            let params = await Constants.shared.tunnel.verificationParameters(isBeta: tunnelContext.iapManager.isBeta)
            pp_log(ctx, .app, .info, "Will start profile verification in \(params.delay) seconds")

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
                    interval: params.interval
                )
            }
        } catch {
            pp_log(ctx, .app, .fault, "Unable to start tunnel: \(error)")
            ctx.flushLog()
            throw error
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason) async {
        verifierSubscription?.cancel()
        await fwd?.stopTunnel(with: reason)
        fwd = nil
        ctx?.flushLog()
    }

    override func cancelTunnelWithError(_ error: (any Error)?) {
        ctx?.flushLog()
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
    func verifyEligibility(of profile: Profile, environment: TunnelEnvironment, interval: TimeInterval) async {
        guard let tunnelContext else {
            fatalError("Missing tunnelContext?")
        }
        while true {
            do {
                pp_log(ctx, .app, .info, "Verify profile, requires: \(profile.features)")
                await tunnelContext.iapManager.reloadReceipt()
                try await tunnelContext.iapManager.verify(profile)
            } catch {
                let error = PartoutError(.App.ineligibleProfile)
                environment.setEnvironmentValue(error.code, forKey: TunnelEnvironmentKeys.lastErrorCode)
                pp_log(ctx, .app, .fault, "Verification failed for profile \(profile.id), shutting down: \(error)")

                // prevent on-demand reconnection
                environment.setEnvironmentValue(true, forKey: TunnelEnvironmentKeys.holdFlag)
                await fwd?.holdTunnel()
                return
            }

            pp_log(ctx, .app, .info, "Will verify profile again in \(interval) seconds...")
            try? await Task.sleep(interval: interval)
        }
    }
}

private extension TunnelEnvironmentKeys {
    static let holdFlag = TunnelEnvironmentKey<Bool>("Tunnel.onHold")
}
