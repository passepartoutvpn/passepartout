//
//  CoreContext.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/4/22.
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
import Foundation
import PassepartoutLibrary
import TunnelKitCore
import TunnelKitManager

@MainActor
final class CoreContext {
    let store: KeyValueStore

    let providerManager: ProviderManager

    let profileManager: ProfileManager

    let vpnManager: VPNManager

    private var cancellables: Set<AnyCancellable> = []

    init(persistenceManager: PersistenceManager) {
        store = persistenceManager.store

        #if !os(tvOS)
        let vpnPersistence = persistenceManager.loadVPNPersistence(
            withName: Constants.Persistence.profilesContainerName
        )
        #endif
        let sharedVPNPersistence = persistenceManager.loadSharedVPNPersistence(
            withName: Constants.Persistence.sharedProfilesContainerName
        )
        let providersPersistence = persistenceManager.loadProvidersPersistence(
            withName: Constants.Persistence.providersContainerName
        )

        let remoteProvidersStrategy = APIRemoteProvidersStrategy(
            appBuild: Constants.Global.appBuildNumber,
            bundleServices: APIWebServices.bundledServices(
                withVersion: Constants.Services.version
            ),
            remoteServices: APIWebServices(
                Constants.Services.version,
                Constants.Repos.api,
                timeout: Constants.Services.connectivityTimeout
            ),
            webServicesRepository: providersPersistence.webServicesRepository()
        )
        providerManager = ProviderManager(
            localProvidersRepository: providersPersistence.localProvidersRepository(),
            remoteProvidersStrategy: remoteProvidersStrategy
        )

        let tvProfileRepository = sharedVPNPersistence.profileRepository()
        #if !os(tvOS)
        let profileRepository = vpnPersistence.profileRepository()
        let sharedProfileRepository = tvProfileRepository
        #else
        let profileRepository = tvProfileRepository
        let sharedProfileRepository: ProfileRepository? = nil
        #endif

        profileManager = ProfileManager(
            store: store,
            providerManager: providerManager,
            profileRepository: profileRepository,
            sharedProfileRepository: sharedProfileRepository,
            keychain: KeychainSecretRepository(appGroup: Constants.App.appGroupId),
            keychainEntry: Unlocalized.Keychain.passwordEntry,
            keychainLabel: Unlocalized.Keychain.passwordLabel
        )

        #if targetEnvironment(simulator)
        let vpn = MockVPN()
        #else
        let vpn = NetworkExtensionVPN()
        #endif
        let vpnManagerStrategy = TunnelKitVPNManagerStrategy(
            appGroup: Constants.App.appGroupId,
            tunnelBundleIdentifier: Constants.App.tunnelBundleId,
            vpn: vpn
        )
        vpnManager = VPNManager(
            store: store,
            profileManager: profileManager,
            providerManager: providerManager,
            strategy: vpnManagerStrategy
        )

        // post

        configureObjects(persistenceManager: persistenceManager)
    }
}

private extension CoreContext {
    func configureObjects(persistenceManager: PersistenceManager) {
        providerManager.rateLimitMilliseconds = Constants.RateLimit.providerManager
        vpnManager.tunnelLogPath = Constants.Log.Tunnel.path
        vpnManager.tunnelLogFormat = Constants.Log.Tunnel.format

        profileManager.observeUpdates()
        vpnManager.observeUpdates()

        CoreConfiguration.masksPrivateData = vpnManager.masksPrivateData
        vpnManager.didUpdatePreferences
            .sink {
                CoreConfiguration.masksPrivateData = $0.masksPrivateData
            }.store(in: &cancellables)

        persistenceManager.didChangePersistence
            .sink { [weak self] in
                self?.reloadPersistenceObjects(persistenceManager: persistenceManager)
            }.store(in: &cancellables)
    }

    func reloadPersistenceObjects(persistenceManager: PersistenceManager) {
        let vpnPersistence = persistenceManager.loadVPNPersistence(
            withName: Constants.Persistence.profilesContainerName
        )
        profileManager.swapProfileRepository(vpnPersistence.profileRepository())
    }
}
