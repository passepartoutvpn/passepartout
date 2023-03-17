//
//  PersistenceManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/22.
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
import PassepartoutCore
import PassepartoutUtils

public final class PersistenceManager {
    private let store: KeyValueStore

    public init(store: KeyValueStore) {
        self.store = store

        // set once
        if persistenceAuthor == nil {
            persistenceAuthor = UUID().uuidString
        }
    }

    public func profilesPersistence(withName containerName: String) -> Persistence {
        let model = PassepartoutDataModels.profiles
        return Persistence(withCloudKitName: containerName, model: model, author: persistenceAuthor)
    }

    public func providersPersistence(withName containerName: String) -> Persistence {
        let model = PassepartoutDataModels.providers
        return Persistence(withLocalName: containerName, model: model, author: persistenceAuthor)
    }
}

// MARK: KeyValueStore

extension PersistenceManager {
    public private(set) var persistenceAuthor: String? {
        get {
            store.value(forLocation: StoreKey.persistenceAuthor)
        }
        set {
            store.setValue(newValue, forLocation: StoreKey.persistenceAuthor)
        }
    }
}

private extension PersistenceManager {
    private enum StoreKey: String, KeyStoreDomainLocation {
        case persistenceAuthor

        var domain: String {
            "Passepartout.PersistenceManager"
        }
    }
}
