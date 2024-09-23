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
        self.registry = registry
        self.constants = constants
        subscriptions = []

        connectionObserver = ConnectionObserver(
            tunnel: tunnel,
            environment: tunnelEnvironment,
            interval: constants.connection.refreshInterval
        )

        observeObjects()
    }
}

private extension AppContext {
    func observeObjects() {
        profileManager
            .didSave
            .sink { [weak self] profile in
                guard let self else {
                    return
                }
                guard profile.id == tunnel.installedProfile?.id else {
                    return
                }
                Task {
                    if profile.isInteractive {
                        try await self.tunnel.disconnect()
                        return
                    }
                    if self.tunnel.status == .active {
                        try await self.tunnel.reconnect(with: profile, processor: self.iapManager)
                    } else {
                        try await self.tunnel.reinstate(profile, processor: self.iapManager)
                    }
                }
            }
            .store(in: &subscriptions)

        profileManager
            .didUpdate
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                guard let installedProfile = tunnel.installedProfile else {
                    return
                }
                guard profileManager.exists(withId: installedProfile.id) else {
                    Task {
                        try await self.tunnel.disconnect()
                    }
                    return
                }
            }
            .store(in: &subscriptions)
    }
}
