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

        observeObjects()
    }

    public func onApplicationActive() {
        guard !isActivating else {
            return
        }
        isActivating = true
        pp_log(.app, .notice, "Application became active")
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    do {
                        try await self.tunnel.prepare(purge: true)
                    } catch {
                        pp_log(.app, .fault, "Unable to prepare tunnel: \(error)")
                    }
                }
                group.addTask { [weak self] in
                    guard let self else {
                        return
                    }
                    await iapManager.reloadReceipt()
                }
            }
            isActivating = false
        }
    }
}

// MARK: - Observation

private extension AppContext {
    func observeObjects() {
        iapManager
            .observeObjects()

        iapManager
            .$eligibleFeatures
            .removeDuplicates()
            .sink { [weak self] in
                self?.syncEligibleFeatures($0)
            }
            .store(in: &subscriptions)

        profileManager
            .observeObjects()

        profileManager
            .didChange
            .sink { [weak self] event in
                switch event {
                case .save(let profile):
                    self?.syncTunnelIfCurrentProfile(profile)

                default:
                    break
                }
            }
            .store(in: &subscriptions)
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

    func syncEligibleFeatures(_ eligible: Set<AppFeature>) {
        let canImport = eligible.contains(.sharing)
        profileManager.enableRemoteImporting(canImport && isCloudKitEnabled)
    }

    func syncTunnelIfCurrentProfile(_ profile: Profile) {
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
