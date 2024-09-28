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

import AppLibrary
import Combine
import CommonLibrary
import Foundation
import PassepartoutKit
import UtilsLibrary

@MainActor
public final class AppContext: ObservableObject {
    public let iapManager: IAPManager

    public let profileManager: ProfileManager

    public let tunnel: Tunnel

    public let tunnelEnvironment: TunnelEnvironment

    public let connectionObserver: ConnectionObserver

    public let registry: Registry

    private let constants: Constants

    private var subscriptions: Set<AnyCancellable>

    public init(
        iapManager: IAPManager,
        profileManager: ProfileManager,
        tunnel: Tunnel,
        tunnelEnvironment: TunnelEnvironment,
        registry: Registry,
        constants: Constants
    ) {
        self.iapManager = iapManager
        self.profileManager = profileManager
        self.tunnel = tunnel
        self.tunnelEnvironment = tunnelEnvironment
        connectionObserver = ConnectionObserver(
            tunnel: tunnel,
            environment: tunnelEnvironment,
            interval: constants.connection.refreshInterval
        )
        self.registry = registry
        self.constants = constants
        subscriptions = []

        profileManager.beforeSave = { [weak self] in
            try await self?.installSavedProfile($0)
        }
        profileManager.afterRemove = { [weak self] in
            self?.uninstallRemovedProfiles(withIds: $0)
        }

        Task {
            try await tunnel.prepare()
            await iapManager.reloadReceipt()
            connectionObserver.observeObjects()
            profileManager.observeObjects()
            observeObjects()
        }
    }
}

// MARK: - Observation

private extension AppContext {
    func observeObjects() {
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
    func installSavedProfile(_ profile: Profile) async throws {
        try await tunnel.install(profile, processor: iapManager)
    }

    func uninstallRemovedProfiles(withIds profileIds: [Profile.ID]) {
        Task {
            for id in profileIds {
                do {
                    try await tunnel.uninstall(profileId: id)
                } catch {
                    pp_log(.app, .error, "Unable to uninstall profile \(id): \(error)")
                }
            }
        }
    }

    func syncTunnelIfCurrentProfile(_ profile: Profile) {
        guard profile.id == tunnel.currentProfile?.id else {
            return
        }
        Task {
            if profile.isInteractive {
                try await tunnel.disconnect()
                return
            }
            if tunnel.status == .active {
                try await tunnel.connect(with: profile, processor: iapManager)
            }
        }
    }
}
