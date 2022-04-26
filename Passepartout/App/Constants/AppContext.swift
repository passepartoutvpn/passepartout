//
//  AppContext.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/17/22.
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
import CoreData
import Combine
import PassepartoutCore
import PassepartoutServices

@MainActor
class AppContext {
    static let shared = AppContext()
    
    private let persistenceManager: PersistenceManager
    
    let appManager: AppManager
    
    let providerManager: ProviderManager
    
    let profileManager: ProfileManager
    
    let vpnManager: VPNManager
    
    let productManager: ProductManager
    
    let intentsManager: IntentsManager

    let reviewer: Reviewer
    
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {
        
        // core
        
        appManager = AppManager()
        appManager.logLevel = Constants.Log.logLevel
        appManager.logFile = Constants.Log.appFileURL
        appManager.logFormat = Constants.Log.appLogFormat
        appManager.tunnelLogFormat = Constants.Log.tunnelLogFormat
        appManager.configureLogging()
        pp_log.info("Logging to: \(appManager.logFile!)")

        persistenceManager = PersistenceManager(author: appManager.persistenceAuthor)

        providerManager = ProviderManager(
            appBuild: Constants.Global.appBuildNumber,
            bundleServices: DefaultWebServices.bundledServices(
                withVersion: Constants.Services.version
            ),
            webServices: DefaultWebServices(
                Constants.Services.version,
                Constants.Repos.api,
                timeout: Constants.Services.connectivityTimeout
            ),
            persistence: persistenceManager.providersPersistence(
                withName: Constants.Persistence.providersContainerName
            )
        )

        profileManager = ProfileManager(
            providerManager: providerManager,
            appGroup: Constants.App.appGroupId,
            keychainLabel: Unlocalized.Keychain.passwordLabel,
            strategy: ProfileManager.CoreDataStrategy(
                persistence: persistenceManager.profilesPersistence(
                    withName: Constants.Persistence.profilesContainerName
                )
            )
        )

        #if targetEnvironment(simulator)
        vpnManager = VPNManager(
            appManager: appManager,
            profileManager: profileManager,
            providerManager: providerManager,
            strategy: VPNManager.MockStrategy()
        )
        #else
        vpnManager = VPNManager(
            appManager: appManager,
            profileManager: profileManager,
            providerManager: providerManager,
            strategy: VPNManager.TunnelKitStrategy(
                appGroup: Constants.App.appGroupId,
                tunnelBundleIdentifier: Constants.App.tunnelBundleId
            )
        )
        #endif

        // app

        productManager = ProductManager(
            appType: Constants.InApp.appType,
            buildProducts: Constants.InApp.buildProducts
        )
        intentsManager = IntentsManager()
        reviewer = Reviewer()
        
        // post
        
        configureObjects()
    }
    
    private func configureObjects() {

        // core

        profileManager.availabilityFilter = {
            self.isEligibleProfile(withHeader: $0)
        }
        if let activeProfileId = appManager.activeProfileId {
            do {
                try profileManager.loadActiveProfile(withId: activeProfileId)
            } catch {
                pp_log.warning("Unable to load active profile: \(error)")
            }
        }
        providerManager.rateLimitMilliseconds = Constants.RateLimit.providerManager
        vpnManager.isOnDemandRulesSupported = {
            self.isEligibleForOnDemandRules()
        }

        profileManager.observeUpdates()
        vpnManager.observeUpdates()

        // app

        reviewer.eventCountBeforeRating = Constants.Rating.eventCount
        vpnManager.currentState.$vpnStatus
            .removeDuplicates()
            .sink {
                if $0 == .connected {
                    pp_log.info("VPN successful connection, report to Reviewer")
                    self.reviewer.reportEvent()
                }
        }.store(in: &cancellables)
    }
    
    // eligibility: hide providers not found or not purchased
    private func isEligibleProfile(withHeader header: Profile.Header) -> Bool {
        guard let providerName = header.providerName else {
            return true // always eligible for non-provider profiles
        }
        guard productManager.isEligible(forProvider: providerName) else {
//            pp_log.debug("Not eligible for provider \(metadata.name)")
            return false
        }
        return true
    }
    
    // eligibility: ignore network settings if ineligible
    private func isEligibleForNetworkSettings() -> Bool {
        guard productManager.isEligible(forFeature: .networkSettings) else {
            pp_log.warning("Ignore network settings, not eligible")
            return false
        }
        return true
    }
    
    // eligibility: reset on-demand rules if no trusted networks
    private func isEligibleForOnDemandRules() -> Bool {
        guard productManager.isEligible(forFeature: .trustedNetworks) else {
            pp_log.warning("Ignore on-demand rules, not eligible for trusted networks")
            return false
        }
        return true
    }
}

extension AppManager {
    static let shared = AppContext.shared.appManager
}

extension ProfileManager {
    static let shared = AppContext.shared.profileManager
}

extension ProviderManager {
    static let shared = AppContext.shared.providerManager
}

extension VPNManager {
    static let shared = AppContext.shared.vpnManager
}

extension ProductManager {
    static let shared = AppContext.shared.productManager
}

extension IntentsManager {
    static let shared = AppContext.shared.intentsManager
}

extension Reviewer {
    static let shared = AppContext.shared.reviewer
}

extension VPNManager.ObservableState {

    @MainActor
    static let shared = AppContext.shared.vpnManager.currentState
}
