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
import CoreData
import SwiftyBeaver
import PassepartoutCore
import PassepartoutUtils

@MainActor
public final class UpgradeManager: ObservableObject {

    // MARK: Initialization

    private let store: KeyValueStore

    // MARK: State

    @Published public private(set) var isDoingMigrations = true

    public init(store: KeyValueStore) {
        self.store = store
    }

    public func doMigrations(_ profileManager: ProfileManager) {
        doMigrateStore(store)

//        profileManager.removeAllProfiles()
        guard didMigrateToV2 else {
            isDoingMigrations = true
            let migrated = doMigrateToV2()
            if !migrated.isEmpty {
                pp_log.info("Migrating \(migrated.count) profiles")
                migrated.forEach {
                    var profile = $0
                    if profileManager.isExistingProfile(withName: profile.header.name) {
                        profile = profile.renamedUniquely(withLastUpdate: true)
                    }
                    profileManager.saveProfile(profile, isActive: nil)
                }
            } else {
                pp_log.info("Nothing to migrate!")
            }
            isDoingMigrations = false

            didMigrateToV2 = true
            return
        }
        isDoingMigrations = false
    }
}

// MARK: KeyValueStore

extension UpgradeManager {
    public internal(set) var didMigrateToV2: Bool {
        get {
            store.value(forLocation: StoreKey.didMigrateToV2) ?? false
        }
        set {
            store.setValue(newValue, forLocation: StoreKey.didMigrateToV2)
        }
    }
}

private extension UpgradeManager {
    private enum StoreKey: String, KeyStoreDomainLocation {
        case didMigrateToV2

        var domain: String {
            "Passepartout.UpgradeManager"
        }
    }
}
