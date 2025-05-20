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
import CommonUtils
@preconcurrency import NetworkExtension

final class PacketTunnelProvider: NEPacketTunnelProvider, @unchecked Sendable {
    private var ctx: PartoutLoggerContext?

    private var fwd: NEPTPForwarder?

    private var verifierSubscription: Task<Void, Error>?

    override func startTunnel(options: [String: NSObject]? = nil) async throws {
        let appPreferences: AppPreferenceValues?
        if let encodedPreferences = options?[ExtendedTunnel.appPreferences] as? NSData {
            do {
                appPreferences = try JSONDecoder()
                    .decode(AppPreferenceValues.self, from: encodedPreferences as Data)
            } catch {
                pp_log_g(.app, .error, "Unable to decode startTunnel() preferences")
                appPreferences = nil
            }
        } else {
            appPreferences = nil
        }

        // MARK: Declare globals

        let dependencies: Dependencies = await .shared
        let constants: Constants = .shared
        await CommonLibrary.assertMissingImplementations(with: dependencies.registry)

        // MARK: Update or fetch existing preferences

        let (kvStore, preferences) = await MainActor.run {
            let kvStore = KeyValueManager(
                store: UserDefaultsStore(.standard),
                fallback: AppPreferenceValues()
            )
            if let appPreferences {
                kvStore.preferences = appPreferences
                return (kvStore, appPreferences)
            } else {
                return (kvStore, kvStore.preferences)
            }
        }

        // MARK: Parse profile

        let processor = DefaultTunnelProcessor()
        let neTunnelController = try await NETunnelController(
            provider: self,
            decoder: dependencies.neProtocolCoder(.global),
            registry: dependencies.registry,
            options: {
                var options = NETunnelController.Options()
                if preferences.dnsFallsBack {
                    options.dnsFallbackServers = constants.tunnel.dnsFallbackServers
                }
                return options
            }(),
            environmentFactory: {
                dependencies.tunnelEnvironment(profileId: $0)
            },
            willProcess: processor.willProcess
        )
        let profileId = neTunnelController.originalProfile.id

        // MARK: Create PartoutLoggerContext with profile

        let ctx = PartoutLogger.register(for: .tunnel(profileId), with: preferences)
        self.ctx = ctx

        pp_log(ctx, .app, .info, "Tunnel started with options: \(options?.description ?? "nil")")
        if let appPreferences {
            pp_log(ctx, .app, .info, "\tDecoded preferences: \(appPreferences)")
        } else {
            pp_log(ctx, .app, .info, "\tExisting preferences: \(preferences)")
        }

        // MARK: Create IAPManager for verification

        let iapManager = await MainActor.run {
            let manager = IAPManager(
                customUserLevel: dependencies.customUserLevel,
                inAppHelper: dependencies.appProductHelper(),
                receiptReader: SharedReceiptReader(
                    reader: StoreKitReceiptReader(logger: dependencies.iapLogger()),
                ),
                betaChecker: dependencies.betaChecker(),
                productsAtBuild: dependencies.productsAtBuild()
            )
#if PP_BUILD_FREE
            manager.isEnabled = false
#else
            manager.isEnabled = !kvStore.bool(forKey: AppPreference.skipsPurchases.key)
#endif
            return manager
        }

        // MARK: Start with NEPTPForwarder

        guard self.ctx != nil else {
            fatalError("Do not forget to save ctx locally")
        }
        do {
            fwd = NEPTPForwarder(ctx, controller: neTunnelController)
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
            await iapManager.fetchLevelIfNeeded()
            let isBeta = await iapManager.isBeta
            let params = constants.tunnel.verificationParameters(isBeta: isBeta)
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
                    iapManager: iapManager,
                    environment: environment,
                    interval: params.interval
                )
            }
        } catch {
            pp_log(ctx, .app, .fault, "Unable to start tunnel: \(error)")
            flushLogs()
            throw error
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason) async {
        verifierSubscription?.cancel()
        await fwd?.stopTunnel(with: reason)
        fwd = nil
        flushLogs()
    }

    override func cancelTunnelWithError(_ error: (any Error)?) {
        flushLogs()
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

private extension PacketTunnelProvider {
    func flushLogs() {
        PartoutLogger.default.flushLog()
    }
}

// MARK: - Eligibility

private extension PacketTunnelProvider {
    func verifyEligibility(
        of profile: Profile,
        iapManager: IAPManager,
        environment: TunnelEnvironment,
        interval: TimeInterval
    ) async {
        guard let ctx else {
            fatalError("Forgot to set ctx?")
        }
        while true {
            do {
                pp_log(ctx, .app, .info, "Verify profile, requires: \(profile.features)")
                await iapManager.reloadReceipt()
                try await iapManager.verify(profile)
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
