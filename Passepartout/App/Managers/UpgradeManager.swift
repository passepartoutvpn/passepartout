//
//  UpgradeManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/8/22.
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

@MainActor
public final class UpgradeManager: ObservableObject {

    // MARK: Initialization

    private let store: KeyValueStore

    private let strategy: UpgradeManagerStrategy

    // MARK: State

    @Published public private(set) var isDoingMigrations = true

    public init(
        store: KeyValueStore,
        strategy: UpgradeManagerStrategy
    ) {
        self.store = store
        self.strategy = strategy
    }

    public func doMigrations(_ profileManager: ProfileManager) {
        strategy.doMigrateStore(store, lastVersion: lastVersion)
        lastVersion = Constants.Global.appVersionNumber

        isDoingMigrations = false
    }
}

// MARK: KeyValueStore

private extension UpgradeManager {
    var lastVersion: String? {
        get {
            store.value(forLocation: StoreKey.lastVersion)
        }
        set {
            store.setValue(newValue, forLocation: StoreKey.lastVersion)
        }
    }
}

private extension UpgradeManager {
    enum StoreKey: String, KeyStoreDomainLocation {
        case lastVersion

        case didMigrateToV2 // temporarily retain for future migrations

        var domain: String {
            "Passepartout.UpgradeManager"
        }
    }
}
