//
//  Persistence.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/7/22.
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

import CoreData
import Foundation
import PassepartoutCore
import PassepartoutProviders
import PassepartoutServices

extension PassepartoutPersistence {
    private static let providersDataModel: NSManagedObjectModel = {
        guard let model = NSManagedObjectModel.mergedModel(from: [.module]) else {
            fatalError("Could not load PassepartoutProviders model")
        }
        return model
    }()

    public static func providersStore(withName containerName: String, cloudKit: Bool, author: String?) -> CoreDataPersistentStore {
        .init(
            withName: containerName,
            model: providersDataModel,
            cloudKit: cloudKit,
            author: author
        )
    }
}

extension PassepartoutPersistence {
    public static func webServicesRepository(_ store: CoreDataPersistentStore) -> WebServicesRepository {
        CDWebServicesRepository(store.context)
    }

    public static func providersFacadeRepository(_ store: CoreDataPersistentStore) -> ProvidersFacadeRepository {
        CDProvidersFacadeRepository(store.context)
    }
}
