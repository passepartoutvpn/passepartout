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

    public let registry: Registry

    public let profileManager: ProfileManager

    public let tunnel: ExtendedTunnel

    public let providerManager: ProviderManager

    private var didLaunch = false

    private var isActivating = false

    private var subscriptions: Set<AnyCancellable>

    public init(
        iapManager: IAPManager,
        registry: Registry,
        profileManager: ProfileManager,
        tunnel: ExtendedTunnel,
        providerManager: ProviderManager
    ) {
        self.iapManager = iapManager
        self.registry = registry
        self.profileManager = profileManager
        self.tunnel = tunnel
        self.providerManager = providerManager
        subscriptions = []
    }
}

// MARK: - Observation

// invoked by AppDelegate
extension AppContext {
    public func onApplicationActive() {
        guard !isActivating else {
            // prevent concurrent invocations
            return
        }
        isActivating = true
        if !didLaunch {
            pp_log(.app, .notice, "Application did launch")
            didLaunch = true
            Task {
                try await onLaunch()
                isActivating = false
            }
        } else {
            pp_log(.app, .notice, "Application entered foreground")
            Task {
                try await onForeground()
                isActivating = false
            }
        }
    }
}

// invoked on internal events
private extension AppContext {
    func onLaunch() async throws {
        try await profileManager.observeLocal()

        iapManager.observeObjects()
        await iapManager.reloadReceipt()

        iapManager
            .$eligibleFeatures
            .removeDuplicates()
            .sink { [weak self] in
                self?.onEligibleFeatures($0)
            }
            .store(in: &subscriptions)

        profileManager
            .didChange
            .sink { [weak self] event in
                switch event {
                case .save(let profile):
                    self?.onSaveProfile(profile)

                default:
                    break
                }
            }
            .store(in: &subscriptions)

        pp_log(.app, .notice, "Fetch providers index...")
        try await providerManager.fetchIndex(from: API.shared)
    }

    func onForeground() async throws {
        try await profileManager.observeLocal()
        await iapManager.reloadReceipt()
    }

    func onEligibleFeatures(_ eligible: Set<AppFeature>) {
        Task {
            let canImport = eligible.contains(.sharing)
            try await profileManager.observeRemote(canImport && isCloudKitEnabled)
        }
    }

    func onSaveProfile(_ profile: Profile) {
        guard profile.id == tunnel.currentProfile?.id else {
            return
        }
        Task {
            guard [.active, .activating].contains(tunnel.status) else {
                return
            }
            if profile.isInteractive {
                try await tunnel.disconnect()
                return
            }
            do {
                try await tunnel.connect(with: profile)
            } catch {
                try await tunnel.disconnect()
            }
        }
    }
}

private extension AppContext {
    var isCloudKitEnabled: Bool {
#if os(tvOS)
        true
#else
        FileManager.default.ubiquityIdentityToken != nil
#endif
    }
}
