//
//  PassepartoutApp.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/28/21.
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

import SwiftUI
import PassepartoutLibrary

@main
struct PassepartoutApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    @SceneBuilder var body: some Scene {
        WindowGroup {
            MainView()
                .withoutTitleBar()
                .onIntentActivity(IntentDispatcher.connectVPN)
                .onIntentActivity(IntentDispatcher.disableVPN)
                .onIntentActivity(IntentDispatcher.enableVPN)
                .onIntentActivity(IntentDispatcher.moveToLocation)
                .onIntentActivity(IntentDispatcher.trustCellularNetwork)
                .onIntentActivity(IntentDispatcher.trustCurrentNetwork)
                .onIntentActivity(IntentDispatcher.untrustCellularNetwork)
                .onIntentActivity(IntentDispatcher.untrustCurrentNetwork)
        }
    }
}

extension View {
    fileprivate func onIntentActivity(_ activity: IntentActivity<VPNManager>) -> some View {
        onContinueUserActivity(activity.name) { userActivity in

            // eligibility: ignore Siri shortcuts if not purchased
            guard AppContext.shared.productManager.isEligible(forFeature: .siriShortcuts) else {
                pp_log.warning("Ignore activity handler, not eligible for Siri shortcuts")
                return
            }
            pp_log.info("Handling activity: \(activity.name)")
            activity.handler(userActivity, CoreContext.shared.vpnManager)
        }
    }
}
