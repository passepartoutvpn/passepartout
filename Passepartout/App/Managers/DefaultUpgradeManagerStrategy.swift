//
//  DefaultUpgradeManagerStrategy.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/20/22.
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

final class DefaultUpgradeManagerStrategy: UpgradeManagerStrategy {
    init() {
    }

    func migrate(store: KeyValueStore, lastVersion: String?) {

        // legacy check before lastVersion was even stored
        let isUpgradeFromBefore_2_2_0: Bool? = store.value(forLocation: UpgradeManager.StoreKey.existingKeyBefore_2_2_0)
        if isUpgradeFromBefore_2_2_0 != nil {
            pp_log.debug("Upgrading from < 2.2.0, iCloud syncing defaults to enabled")
            store.setValue(true, forLocation: PersistenceManager.StoreKey.shouldEnableCloudSyncing)
            store.removeValue(forLocation: UpgradeManager.StoreKey.existingKeyBefore_2_2_0)
        }

        guard let lastVersion else {
            pp_log.debug("Fresh install")
            return
        }
        pp_log.debug("Upgrade from \(lastVersion)")
    }

    func migrateData() {
    }
}
