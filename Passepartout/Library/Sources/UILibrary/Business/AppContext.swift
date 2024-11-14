//
//  AppContext.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/29/24.
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

import Combine
import CommonLibrary
import CommonUtils
import Foundation
import PassepartoutKit

@MainActor
public final class AppContext: ObservableObject {
    public let iapManager: IAPManager

    public let migrationManager: MigrationManager

    public let profileManager: ProfileManager

    public let providerManager: ProviderManager

    public let registry: Registry

    public let tunnel: ExtendedTunnel

    private var launchTask: Task<Void, Error>?

    private var pendingTask: Task<Void, Never>?

    private var subscriptions: Set<AnyCancellable>

    public init(
        iapManager: IAPManager,
        migrationManager: MigrationManager,
        profileManager: ProfileManager,
        providerManager: ProviderManager,
        registry: Registry,
        tunnel: ExtendedTunnel
    ) {
        self.iapManager = iapManager
        self.migrationManager = migrationManager
        self.profileManager = profileManager
        self.providerManager = providerManager
        self.registry = registry
        self.tunnel = tunnel
        subscriptions = []
    }
}

// MARK: - Observation

// invoked by AppDelegate
extension AppContext {
    public func onApplicationActive() {
        Task {
            // TODO: ###, should handle AppError.couldNotLaunch (although extremely rare)
            try await onForeground()
        }
    }
}

// invoked on internal events
private extension AppContext {
    func onLaunch() async throws {
        pp_log(.app, .notice, "Application did launch")

        pp_log(.App.profiles, .info, "Read and observe local profiles...")
        try await profileManager.observeLocal()

        iapManager.observeObjects()
        await iapManager.reloadReceipt()

        iapManager
            .$eligibleFeatures
            .removeDuplicates()
            .sink { [weak self] eligible in
                Task {
                    try await self?.onEligibleFeatures(eligible)
                }
            }
            .store(in: &subscriptions)

        profileManager
            .didChange
            .sink { [weak self] event in
                switch event {
                case .save(let profile):
                    Task {
                        try await self?.onSaveProfile(profile)
                    }

                default:
                    break
                }
            }
            .store(in: &subscriptions)

        // copy release receipt to tunnel for TestFlight eligibility (once is enough, it won't change)
        if let appReceiptURL = Bundle.main.appStoreProductionReceiptURL {
            let tunnelReceiptURL = BundleConfiguration.urlForBetaReceipt
            do {
                pp_log(.App.iap, .info, "Copy release receipt to tunnel...")
                try? FileManager.default.removeItem(at: tunnelReceiptURL)
                try FileManager.default.copyItem(at: appReceiptURL, to: tunnelReceiptURL)
            } catch {
                pp_log(.App.iap, .error, "Unable to copy release receipt to tunnel: \(error)")
            }
        }

        do {
            pp_log(.app, .notice, "Fetch providers index...")
            try await providerManager.fetchIndex(from: API.shared)
        } catch {
            pp_log(.app, .error, "Unable to fetch providers index: \(error)")
        }
    }

    func onForeground() async throws {
        let didLaunch = try await waitForTasks()
        guard !didLaunch else {
            return // foreground is redundant after launch
        }

        pp_log(.app, .notice, "Application did enter foreground")
        pendingTask = Task {
            do {
                pp_log(.App.profiles, .info, "Refresh local profiles observers...")
                try await profileManager.observeLocal()
            } catch {
                pp_log(.App.profiles, .error, "Unable to re-observe local profiles: \(error)")
            }

            await iapManager.reloadReceipt()
        }
        await pendingTask?.value
        pendingTask = nil
    }

    func onEligibleFeatures(_ features: Set<AppFeature>) async throws {
        try await waitForTasks()

        pp_log(.app, .notice, "Application did update eligible features")
        pendingTask = Task {

            // toggle sync based on .sharing eligibility
            let isEligibleForSharing = features.contains(.sharing)
            do {
                pp_log(.App.profiles, .info, "Refresh remote profiles observers (eligible=\(isEligibleForSharing), CloudKit=\(isCloudKitEnabled))...")
                try await profileManager.observeRemote(isEligibleForSharing && isCloudKitEnabled)
            } catch {
                pp_log(.App.profiles, .error, "Unable to re-observe remote profiles: \(error)")
            }
        }
        await pendingTask?.value
        pendingTask = nil
    }

    func onSaveProfile(_ profile: Profile) async throws {
        try await waitForTasks()

        pp_log(.app, .notice, "Application did save profile (\(profile.id))")
        guard profile.id == tunnel.currentProfile?.id else {
            pp_log(.app, .debug, "Profile \(profile.id) is not current, do nothing")
            return
        }
        guard [.active, .activating].contains(tunnel.status) else {
            pp_log(.app, .debug, "Connection is not active (\(tunnel.status)), do nothing")
            return
        }
        pendingTask = Task {
            do {
                if profile.isInteractive {
                    pp_log(.app, .info, "Profile \(profile.id) is interactive, disconnect")
                    try await tunnel.disconnect()
                    return
                }
                do {
                    pp_log(.app, .info, "Reconnect profile \(profile.id)")
                    try await tunnel.connect(with: profile)
                } catch {
                    pp_log(.app, .error, "Unable to reconnect profile \(profile.id), disconnect: \(error)")
                    try await tunnel.disconnect()
                }
            } catch {
                pp_log(.app, .error, "Unable to reinstate connection on save profile \(profile.id): \(error)")
            }
        }
        await pendingTask?.value
        pendingTask = nil
    }

    @discardableResult
    func waitForTasks() async throws -> Bool {
        var didLaunch = false

        // must launch once before anything else
        if launchTask == nil {
            launchTask = Task {
                do {
                    try await onLaunch()
                } catch {
                    launchTask = nil // redo launch
                    throw AppError.couldNotLaunch(reason: error)
                }
            }
            didLaunch = true
        }

        // will throw on .couldNotLaunch
        // next wait will re-attempt launch (launchTask == nil)
        try await launchTask?.value

        // wait for pending task if any
        await pendingTask?.value
        pendingTask = nil

        return didLaunch
    }
}

// MARK: - Helpers

private extension AppContext {
    var isCloudKitEnabled: Bool {
#if os(tvOS)
        true
#else
        FileManager.default.ubiquityIdentityToken != nil
#endif
    }
}
