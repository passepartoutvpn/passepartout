// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import AppAccessibility
import Combine
import CommonLibrary
import CommonUtils
import Foundation

@MainActor
public final class AppContext: ObservableObject, Sendable {
    public let apiManager: APIManager

    public let appearanceManager: AppearanceManager

    public let configManager: ConfigManager

    public let distributionTarget: DistributionTarget

    public let iapManager: IAPManager

    public let kvManager: KeyValueManager

    public let migrationManager: MigrationManager

    public let onboardingManager: OnboardingManager

    public let preferencesManager: PreferencesManager

    public let profileManager: ProfileManager

    public let registry: Registry

    public let registryCoder: RegistryCoder

    public let sysexManager: SystemExtensionManager?

    public let tunnel: ExtendedTunnel

    public let versionChecker: VersionChecker

    public let webReceiverManager: WebReceiverManager

    private let onEligibleFeaturesBlock: ((Set<AppFeature>) async -> Void)?

    private var launchTask: Task<Void, Error>?

    private var pendingTask: Task<Void, Never>?

    private var subscriptions: Set<AnyCancellable>

    public init(
        apiManager: APIManager,
        configManager: ConfigManager,
        distributionTarget: DistributionTarget,
        iapManager: IAPManager,
        kvManager: KeyValueManager,
        migrationManager: MigrationManager,
        onboardingManager: OnboardingManager? = nil,
        preferencesManager: PreferencesManager,
        profileCoder: ProfileCoder,
        profileManager: ProfileManager,
        registry: Registry,
        sysexManager: SystemExtensionManager?,
        tunnel: ExtendedTunnel,
        versionChecker: VersionChecker? = nil,
        webReceiverManager: WebReceiverManager,
        onEligibleFeaturesBlock: ((Set<AppFeature>) async -> Void)? = nil
    ) {
        self.apiManager = apiManager
        appearanceManager = AppearanceManager(kvManager: kvManager)
        self.configManager = configManager
        self.distributionTarget = distributionTarget
        self.iapManager = iapManager
        self.kvManager = kvManager
        self.migrationManager = migrationManager
        self.onboardingManager = onboardingManager ?? OnboardingManager()
        self.preferencesManager = preferencesManager
        self.profileManager = profileManager
        self.registry = registry
        self.registryCoder = registry.with(coder: profileCoder)
        self.sysexManager = sysexManager
        self.tunnel = tunnel
        self.versionChecker = versionChecker ?? VersionChecker()
        self.webReceiverManager = webReceiverManager
        self.onEligibleFeaturesBlock = onEligibleFeaturesBlock
        subscriptions = []
    }
}

// MARK: - Observation

// invoked by AppDelegate
extension AppContext {
    public func onApplicationActive() {
        Task {
            // XXX: Should handle AppError.couldNotLaunch (although extremely rare)
            try await onForeground()

            await configManager.refreshBundle()
            await versionChecker.checkLatestRelease()

            // Use NESocket in tunnel if .neSocket ConfigFlag is active
            let shouldUseNESocket = configManager.isActive(.neSocket)
            kvManager.set(shouldUseNESocket, forKey: AppPreference.usesNESocket.key)
        }
    }
}

// invoked on internal events
private extension AppContext {
    func onLaunch() async throws {
        pp_log_g(.app, .notice, "Application did launch")

        pp_log_g(.App.profiles, .info, "\tRead and observe local profiles...")
        try await profileManager.observeLocal()

        pp_log_g(.App.profiles, .info, "\tObserve in-app events...")
        iapManager.observeObjects(withProducts: true)

        // Defer loads to not block app launch
        Task {
            await iapManager.reloadReceipt()
        }
        Task {
            await reloadSystemExtension()
        }

        iapManager
            .$isEnabled
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] in
                pp_log_g(.App.iap, .info, "IAPManager.isEnabled -> \($0)")
                self?.kvManager.set(!$0, forKey: AppPreference.skipsPurchases.key)
                Task {
                    await self?.iapManager.reloadReceipt()
                }
            }
            .store(in: &subscriptions)

        pp_log_g(.App.profiles, .info, "\tObserve eligible features...")
        iapManager
            .$eligibleFeatures
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] eligible in
                Task {
                    try await self?.onEligibleFeatures(eligible)
                }
            }
            .store(in: &subscriptions)

        pp_log_g(.App.profiles, .info, "\tObserve changes in ProfileManager...")
        profileManager
            .didChange
            .sink { [weak self] event in
                switch event {
                case .save(let profile, let previousProfile):
                    Task {
                        try await self?.onSaveProfile(profile, previous: previousProfile)
                    }

                default:
                    break
                }
            }
            .store(in: &subscriptions)

        do {
            pp_log_g(.app, .info, "\tFetch providers index...")
            try await apiManager.fetchIndex()
        } catch {
            pp_log_g(.app, .error, "\tUnable to fetch providers index: \(error)")
        }
    }

    func onForeground() async throws {

        // onForeground() is redundant after launch
        let didLaunch = try await waitForTasks()
        guard !didLaunch else {
            return
        }

        pp_log_g(.app, .notice, "Application did enter foreground")
        pendingTask = Task {
            await reloadSystemExtension()

            // FIXME: #1358
            // If the receipt was loaded once, do not invalidate it
            // before a minimum interval (10/30/60 minutes)
            await iapManager.reloadReceipt()
        }
        await pendingTask?.value
        pendingTask = nil
    }

    func onEligibleFeatures(_ features: Set<AppFeature>) async throws {
        try await waitForTasks()

        pp_log_g(.app, .notice, "Application did update eligible features")
        pendingTask = Task {
            await onEligibleFeaturesBlock?(features)
        }
        await pendingTask?.value
        pendingTask = nil
    }

    func onSaveProfile(_ profile: Profile, previous: Profile?) async throws {
        try await waitForTasks()

        pp_log_g(.app, .notice, "Application did save profile (\(profile.id))")
        guard let previous else {
            pp_log_g(.app, .debug, "\tProfile \(profile.id) is new, do nothing")
            return
        }
        let diff = profile.differences(from: previous)
        guard diff.isRelevantForReconnecting(to: profile) else {
            pp_log_g(.app, .debug, "\tProfile \(profile.id) changes are not relevant, do nothing")
            return
        }
        guard tunnel.isActiveProfile(withId: profile.id) else {
            pp_log_g(.app, .debug, "\tProfile \(profile.id) is not current, do nothing")
            return
        }
        let status = tunnel.status(ofProfileId: profile.id)
        guard [.active, .activating].contains(status) else {
            pp_log_g(.app, .debug, "\tConnection is not active (\(status)), do nothing")
            return
        }

        pendingTask = Task {
            do {
                pp_log_g(.app, .info, "\tReconnect profile \(profile.id)")
                try await tunnel.disconnect(from: profile.id)
                do {
                    try await tunnel.connect(with: profile)
                } catch AppError.interactiveLogin {
                    pp_log_g(.app, .info, "\tProfile \(profile.id) is interactive, do not reconnect")
                } catch {
                    pp_log_g(.app, .error, "\tUnable to reconnect profile \(profile.id): \(error)")
                }
            } catch {
                pp_log_g(.app, .error, "\tUnable to reinstate connection on save profile \(profile.id): \(error)")
            }
        }
        await pendingTask?.value
        pendingTask = nil
    }

    @discardableResult
    func waitForTasks() async throws -> Bool {
        var didLaunch = false

        // Require launch task to complete before performing anything else
        if launchTask == nil {
            launchTask = Task {
                do {
                    try await onLaunch()
                } catch {
                    launchTask = nil // Redo the launch task
                    throw AppError.couldNotLaunch(reason: error)
                }
            }
            didLaunch = true
        }

        // Will throw on .couldNotLaunch, and the next await
        // will re-attempt launch because launchTask == nil
        try await launchTask?.value

        // Wait for pending task if any
        await pendingTask?.value
        pendingTask = nil

        return didLaunch
    }

    func reloadSystemExtension() async {
        guard let sysexManager else {
            return
        }
        pp_log_g(.app, .info, "System Extension: load current status...")
        do {
            let result = try await sysexManager.load()
            pp_log_g(.app, .info, "System Extension: load result is \(result)")
        } catch {
            pp_log_g(.app, .error, "System Extension: load error: \(error)")
        }
    }
}

extension Collection where Element == Profile.DiffResult {
    func isRelevantForReconnecting(to profile: Profile) -> Bool {
        contains {
            switch $0 {
            case .changedName:
                // Do not reconnect on profile rename
                return false
            case .changedModules(let ids):
                // Do not reconnect if only an on-demand module was changed
                if ids.count == 1, let onlyID = ids.first,
                   profile.module(withId: onlyID) is OnDemandModule {
                    return false
                }
                return true
            default:
                return true
            }
        }
    }
}
