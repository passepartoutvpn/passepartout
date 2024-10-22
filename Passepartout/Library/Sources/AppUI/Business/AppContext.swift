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

    public let profileProcessor: ProfileProcessor

    public let tunnel: Tunnel

    public let tunnelEnvironment: TunnelEnvironment

    public let connectionObserver: ConnectionObserver

    public let registry: Registry

    public let providerManager: ProviderManager

    private let constants: Constants

    private var subscriptions: Set<AnyCancellable>

    public init(
        iapManager: IAPManager,
        profileManager: ProfileManager,
        profileProcessor: ProfileProcessor,
        tunnel: Tunnel,
        tunnelEnvironment: TunnelEnvironment,
        registry: Registry,
        providerManager: ProviderManager,
        constants: Constants
    ) {
        self.iapManager = iapManager
        self.profileManager = profileManager
        self.profileProcessor = profileProcessor
        self.tunnel = tunnel
        self.tunnelEnvironment = tunnelEnvironment
        connectionObserver = ConnectionObserver(
            tunnel: tunnel,
            environment: tunnelEnvironment,
            interval: constants.tunnel.refreshInterval
        )
        self.registry = registry
        self.providerManager = providerManager
        self.constants = constants
        subscriptions = []

        Task {
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
    func syncTunnelIfCurrentProfile(_ profile: Profile) {
        guard profile.id == tunnel.currentProfile?.id else {
            return
        }
        Task {
            if profile.isInteractive {
                try await tunnel.disconnect()
                return
            }
            // FIXME: #379, reconnect in some scenarios, e.g. changing provider server
        }
    }
}
