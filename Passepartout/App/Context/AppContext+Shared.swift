//
//  AppContext+Shared.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/15/22.
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

import Foundation
import PassepartoutLibrary

// safer alternative to @EnvironmentObject

// MARK: App

extension AppContext {
    static let shared = AppContext(store: UserDefaultsStore(defaults: .standard, key: \.key))
}

extension UpgradeManager {
    static let shared = AppContext.shared.upgradeManager
}

extension ProductManager {
    static let shared = AppContext.shared.productManager
}

extension PersistenceManager {
    static let shared = AppContext.shared.persistenceManager
}

// MARK: App -> Core

extension ProfileManager {
    static let shared = AppContext.shared.profileManager
}

extension ProviderManager {
    static let shared = AppContext.shared.providerManager
}

extension VPNManager {
    static let shared = AppContext.shared.vpnManager
}

extension ObservableVPNState {

    @MainActor
    static let shared = AppContext.shared.vpnManager.currentState
}
