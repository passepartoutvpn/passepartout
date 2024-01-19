//
//  AppContext.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/17/22.
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

@MainActor
final class AppContext {
    private let coreContext: CoreContext

    let upgradeManager: UpgradeManager

    let productManager: ProductManager

    let persistenceManager: PersistenceManager

    private let reviewer: Reviewer

    private var cancellables: Set<AnyCancellable> = []

    init(store: KeyValueStore) {
        let logger = SwiftyBeaverLogger(
            logFile: Constants.Log.App.url,
            logLevel: Constants.Log.level,
            logFormat: Constants.Log.App.format
        )
        Passepartout.shared.logger = logger
        pp_log.info("Logging to: \(logger.logFile!)")

        upgradeManager = UpgradeManager(
            store: store,
            strategy: DefaultUpgradeManagerStrategy()
        )
        upgradeManager.migrate(toVersion: Constants.Global.appVersionNumber)

        productManager = ProductManager(
            inApp: StoreKitInApp<LocalProduct>(),
            receiptReader: StoreKitReceiptReader(),
            overriddenAppType: Constants.InApp.overriddenAppType,
            buildProducts: Constants.InApp.buildProducts
        )

        persistenceManager = PersistenceManager(
            store: store,
            ckContainerId: Constants.CloudKit.containerId,
            ckSharedContainerId: Constants.CloudKit.sharedContainerId,
            ckCoreDataZone: Constants.CloudKit.coreDataZone
        )

        reviewer = Reviewer()
        reviewer.eventCountBeforeRating = Constants.Rating.eventCount

        coreContext = CoreContext(persistenceManager: persistenceManager)

        // post

        configureObjects()
    }

    var providerManager: ProviderManager {
        coreContext.providerManager
    }

    var profileManager: ProfileManager {
        coreContext.profileManager
    }

    var vpnManager: VPNManager {
        coreContext.vpnManager
    }
}

private extension AppContext {
    func configureObjects() {
        coreContext.profileManager.willSaveSharedProfile = { [unowned self] in
            willSaveSharedProfile(withNewProfile: $0, existingProfile: $1)
        }

        coreContext.vpnManager.isOnDemandRulesSupported = {
            self.isEligibleForOnDemandRules()
        }
        coreContext.vpnManager.isNetworkSettingsSupported = {
            self.isEligibleForNetworkSettings()
        }

        coreContext.vpnManager.userData = {
            if let expirationDate = $0.connectionExpirationDate {
                return [Constants.Tunnel.expirationTimeIntervalKey: expirationDate.timeIntervalSinceReferenceDate]
            }
            return nil
        }

        coreContext.vpnManager.currentState.$vpnStatus
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if $0 == .connected {
                    pp_log.info("VPN successful connection, report to Reviewer")
                    self?.reviewer.reportEvent()
                }
            }.store(in: &cancellables)
    }

    // eligibility: ignore network settings if ineligible
    func isEligibleForNetworkSettings() -> Bool {
        guard productManager.isEligible(forFeature: .networkSettings) else {
            pp_log.warning("Ignore network settings, not eligible")
            return false
        }
        return true
    }

    // eligibility: reset on demand rules if no trusted networks
    func isEligibleForOnDemandRules() -> Bool {
        guard productManager.isEligible(forFeature: .trustedNetworks) else {
            pp_log.warning("Ignore on demand rules, not eligible for trusted networks")
            return false
        }
        return true
    }

    // eligibility: expire restricted TV profiles after N minutes
    func willSaveSharedProfile(withNewProfile newProfile: Profile, existingProfile: Profile?) -> Profile {
        if let existingProfile {
            assert(newProfile.id == existingProfile.id)
        }

        guard productManager.isEligible(forFeature: .appleTV) else {
            var restricted = newProfile
            let remainingMinutes: Int
            let expirationDate: Date

            // retain current expiration period if any
            if let existingProfile, let currentExpirationDate = existingProfile.connectionExpirationDate {
                remainingMinutes = Int(currentExpirationDate.timeIntervalSinceNow / 60.0)
                expirationDate = currentExpirationDate

                restricted.connectionExpirationDate = currentExpirationDate
            }
            // otherwise, expire in N minutes from now
            else {
                remainingMinutes = Constants.InApp.tvLimitedMinutes
                expirationDate = Date()
                    .addingTimeInterval(TimeInterval(remainingMinutes) * 60.0)

                restricted.connectionExpirationDate = expirationDate
            }

            if remainingMinutes > 0 {
                pp_log.warning("\(newProfile.logDescription): TV connection expires in \(remainingMinutes) minutes (at \(expirationDate))")
            } else {
                pp_log.warning("\(newProfile.logDescription): TV connection expired at \(expirationDate)")
            }

            return restricted
        }

        return newProfile
    }
}
