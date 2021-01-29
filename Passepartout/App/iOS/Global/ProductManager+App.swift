//
//  ProductManager+App.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/19.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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
import PassepartoutCore
import TunnelKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

extension ProductManager {
    static let shared = ProductManager(
        Configuration(
            isBetaFullVersion: AppConstants.InApp.isBetaFullVersion,
            lastFullVersionBuild: AppConstants.InApp.lastFullVersionBuild
        )
    )

    public func reviewPurchases() {
        let service = TransientStore.shared.service
        reloadReceipt(andNotify: false)
        let isFullVersion = (try? isEligible(forFeature: .fullVersion)) ?? false
        var anyRefund = false

        // review features and potentially revert them if they were used (Siri is handled in AppDelegate)

        log.debug("Checking 'Trusted networks'")
        if isCancelledPurchase(.fullVersion) || (!isFullVersion && isCancelledPurchase(.trustedNetworks)) {
            
            // reset trusted networks for ALL profiles (must load first)
            for key in service.allProfileKeys() {
                guard let profile = service.profile(withKey: key) else {
                    continue
                }
                #if os(iOS)
                if profile.trustedNetworks.includesMobile || !profile.trustedNetworks.includedWiFis.isEmpty {
                    profile.trustedNetworks.includesMobile = false
                    profile.trustedNetworks.includedWiFis.removeAll()
                    anyRefund = true
                }
                #else
                if !profile.trustedNetworks.includedWiFis.isEmpty {
                    profile.trustedNetworks.includedWiFis.removeAll()
                    anyRefund = true
                }
                #endif
            }
            if anyRefund {
                log.debug("\tRefunded")
            }
        }

        log.debug("Checking providers")
        for name in service.providerNames() {
            guard let metadata = InfrastructureFactory.shared.metadata(forName: name) else {
                continue
            }
            if isCancelledPurchase(.fullVersion) || (!isFullVersion && isCancelledPurchase(metadata.product)) {
                service.removeProfile(ProfileKey(name))
                log.debug("\tRefunded provider: \(name)")
                anyRefund = true
            }
        }
        
        guard anyRefund else {
            return
        }

        //

        // save reverts and remove fraud VPN profile
        TransientStore.shared.serialize(withProfiles: true)
        VPN.shared.uninstall(completionHandler: nil)

        NotificationCenter.default.post(name: ProductManager.didReviewPurchases, object: nil)
    }
}
