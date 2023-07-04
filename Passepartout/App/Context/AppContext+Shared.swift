//
//  AppContext+Shared.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/15/22.
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
import PassepartoutLibrary

// safer alternative to @EnvironmentObject

extension AppContext {
    private static let coreContext = CoreContext(store: UserDefaultsStore(defaults: .standard, key: \.key))

    static let shared = AppContext(coreContext: coreContext)
}

extension ProductManager {
    static let shared = AppContext.shared.productManager
}

extension UpgradeManager {
    static let shared = AppContext.shared.upgradeManager
}

extension ProfileManager {
    static let shared = AppContext.shared.profileManager
}

extension ProviderManager {

    @MainActor
    static let shared = AppContext.shared.providerManager
}

extension VPNManager {
    static let shared = AppContext.shared.vpnManager
}

extension ObservableVPNState {

    @MainActor
    static let shared = AppContext.shared.vpnManager.currentState
}
