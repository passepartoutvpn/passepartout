//
//  AppConstants+Flags.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 11/2/19.
//  Copyright (c) 2020 Davide De Rosa. All rights reserved.
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

extension AppConstants {
    struct Rating {
        static let eventCount = 3
    }

    struct Flags {
        static var isBeta: Bool {
            #if targetEnvironment(simulator)
            return true
            #else
            return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
            #endif
        }

        static var isBetaFullVersion: Bool {
            guard !ProcessInfo.processInfo.arguments.contains("FULL_VERSION") else {
                return true
            }
            return false
        }

        static var isMockVPN = false {
            didSet {
                VPN.isMockVPN = isMockVPN
            }
        }

        static let isShowingKickstarter = true

        static let kickstarterURL = URL(string: "https://www.kickstarter.com/projects/keeshux/passepartout-your-only-multi-provider-vpn-client/")!
    }

    struct InApp {
        public static let limitedNumberOfHosts = 2
    }
}
