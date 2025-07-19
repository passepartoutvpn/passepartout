//
//  Dependencies+IAPManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/2/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import CommonUtils

extension Dependencies {
    nonisolated var customUserLevel: AppUserLevel? {
        guard let userLevelInteger = BundleConfiguration.mainIntegerIfPresent(for: .userLevel),
              let userLevel = AppUserLevel(rawValue: userLevelInteger) else {
            return nil
        }
        return userLevel
    }

    func appProductHelper() -> any AppProductHelper {
        StoreKitHelper(
            products: AppProduct.all,
            inAppIdentifier: {
                let prefix = BundleConfiguration.mainString(for: .iapBundlePrefix)
                return "\(prefix).\($0.rawValue)"
            }
        )
    }

    nonisolated func betaChecker() -> BetaChecker {
        TestFlightChecker()
    }

    nonisolated func productsAtBuild() -> BuildProducts<AppProduct> {
        { purchase in
#if os(iOS)
            if purchase.buildNumber <= 2016 {
                return [.Essentials.iOS]
            } else if purchase.buildNumber <= 3000 {
                return [.Features.networkSettings]
            }
            return []
#elseif os(macOS)
            if purchase.buildNumber <= 3000 {
                return [.Features.networkSettings]
            }
            return []
#else
            return []
#endif
        }
    }

    nonisolated func iapLogger() -> LoggerProtocol {
        IAPLogger()
    }
}

private struct IAPLogger: LoggerProtocol {
    func debug(_ msg: String) {
        pp_log_g(.App.iap, .info, msg)
    }

    func warning(_ msg: String) {
        pp_log_g(.App.iap, .error, msg)
    }
}
