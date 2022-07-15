//
//  CoreContext.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/4/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

import Foundation
import Combine
import PassepartoutLibrary

enum Impl {
    typealias ProfileManager = DefaultProfileManager

    typealias ProviderManager = DefaultProviderManager

    typealias VPNManager = DefaultVPNManager<DefaultProfileManager>
}

class CoreContext {
    let store: KeyValueStore
    
    private let profilesPersistence: Persistence
    
    private let providersPersistence: Persistence
    
    var urlsForProfiles: [URL]? {
        profilesPersistence.containerURLs
    }

    var urlsForProviders: [URL]? {
        providersPersistence.containerURLs
    }

    let upgradeManager: UpgradeManager
    
    let providerManager: Impl.ProviderManager
    
    let profileManager: Impl.ProfileManager
    
    let vpnManager: Impl.VPNManager
    
    private var cancellables: Set<AnyCancellable> = []
    
    @MainActor
    init(store: KeyValueStore) {
        self.store = store
        
        let persistenceManager = PersistenceManager(store: store)
        profilesPersistence = persistenceManager.profilesPersistence(
            withName: Constants.Persistence.profilesContainerName
        )
        providersPersistence = persistenceManager.providersPersistence(
            withName: Constants.Persistence.providersContainerName
        )

        upgradeManager = UpgradeManager(store: store)

        providerManager = DefaultProviderManager(
            appBuild: Constants.Global.appBuildNumber,
            bundleServices: DefaultWebServices.bundledServices(
                withVersion: Constants.Services.version
            ),
            webServices: DefaultWebServices(
                Constants.Services.version,
                Constants.Repos.api,
                timeout: Constants.Services.connectivityTimeout
            ),
            persistence: providersPersistence
        )

        profileManager = DefaultProfileManager(
            store: store,
            providerManager: providerManager,
            appGroup: Constants.App.appGroupId,
            keychainLabel: Unlocalized.Keychain.passwordLabel,
            strategy: CoreDataProfileManagerStrategy(
                persistence: profilesPersistence
            )
        )

        #if targetEnvironment(simulator)
        let strategy = VPNManager.MockStrategy()
        #else
        let strategy = TunnelKitVPNManagerStrategy(
            appGroup: Constants.App.appGroupId,
            tunnelBundleIdentifier: Constants.App.tunnelBundleId
        )
        #endif
        vpnManager = DefaultVPNManager(
            appGroup: Constants.App.appGroupId,
            store: store,
            profileManager: profileManager,
            providerManager: providerManager,
            strategy: strategy
        )
        
        // post
        
        configureObjects()
    }
    
    private func configureObjects() {
        providerManager.rateLimitMilliseconds = Constants.RateLimit.providerManager
        vpnManager.tunnelLogPath = Constants.Log.tunnelLogPath
        vpnManager.tunnelLogFormat = Constants.Log.tunnelLogFormat

        profileManager.observeUpdates()
        vpnManager.observeUpdates()
    }
}
