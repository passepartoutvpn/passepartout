//
//  AppContext.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/17/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

@MainActor
class AppContext {
    let logManager: LogManager

    let productManager: ProductManager

    private let reviewer: Reviewer

    private var cancellables: Set<AnyCancellable> = []

    init(coreContext: CoreContext) {
        logManager = LogManager(logFile: Constants.Log.App.url)
        logManager.logLevel = Constants.Log.level
        logManager.logFormat = Constants.Log.App.format
        logManager.configureLogging()
        pp_log.info("Logging to: \(logManager.logFile!)")

        productManager = ProductManager(
            appType: Constants.InApp.appType,
            buildProducts: Constants.InApp.buildProducts
        )

        reviewer = Reviewer()
        reviewer.eventCountBeforeRating = Constants.Rating.eventCount

        // post

        configureObjects(coreContext: coreContext)
    }

    private func configureObjects(coreContext: CoreContext) {
        coreContext.vpnManager.isOnDemandRulesSupported = {
            self.isEligibleForOnDemandRules()
        }

        coreContext.vpnManager.currentState.$vpnStatus
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink {
                if $0 == .connected {
                    pp_log.info("VPN successful connection, report to Reviewer")
                    self.reviewer.reportEvent()
                }
            }.store(in: &cancellables)

        productManager.didRefundProducts
            .receive(on: DispatchQueue.main)
            .sink {
                Task {
                    pp_log.info("Refunds detected, uninstalling VPN profile")
                    await coreContext.vpnManager.uninstall()
                }
            }.store(in: &cancellables)
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
