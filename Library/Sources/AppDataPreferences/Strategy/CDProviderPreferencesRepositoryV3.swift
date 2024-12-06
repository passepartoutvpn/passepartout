//
//  CDProviderPreferencesRepositoryV3.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/5/24.
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

import AppData
import CommonLibrary
import CoreData
import Foundation
import PassepartoutKit

extension AppData {

    @MainActor
    public static func cdProviderPreferencesRepositoryV3(context: NSManagedObjectContext) -> ProviderPreferencesRepository {
        CDProviderPreferencesRepositoryV3(context: context)
    }
}

// MARK: - Repository

private final class CDProviderPreferencesRepositoryV3: ProviderPreferencesRepository {
    private nonisolated let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func providerPreferencesProxy(in providerId: ProviderID) throws -> ProviderPreferencesProxy {
        let entity = try context.performAndWait {
            let request = CDProviderPreferencesV3.fetchRequest()
            request.predicate = NSPredicate(format: "providerId == %@", providerId.rawValue)
            do {
                let entity = try request.execute().first ?? CDProviderPreferencesV3(context: context)
                entity.providerId = providerId.rawValue
                return entity
            } catch {
                pp_log(.app, .error, "Unable to load preferences for provider \(providerId): \(error)")
                throw error
            }
        }
        return CDProviderPreferencesProxy(context: context, entity: entity)
    }
}

// MARK: - Preference

private final class CDProviderPreferencesProxy: ProviderPreferencesProxy {
    private let context: NSManagedObjectContext

    private let entity: CDProviderPreferencesV3

    init(context: NSManagedObjectContext, entity: CDProviderPreferencesV3) {
        self.context = context
        self.entity = entity
    }

    var favoriteServers: Set<String> {
        get {
            do {
                return try context.performAndWait {
                    guard let data = entity.favoriteServerIds else {
                        return []
                    }
                    return try JSONDecoder().decode(Set<String>.self, from: data)
                }
            } catch {
                pp_log(.app, .error, "Unable to get favoriteServers: \(error)")
                return []
            }
        }
        set {
            do {
                try context.performAndWait {
                    entity.favoriteServerIds = try JSONEncoder().encode(newValue)
                }
            } catch {
                pp_log(.app, .error, "Unable to set favoriteServers: \(error)")
            }
        }
    }

    func save() throws {
        guard context.hasChanges else {
            return
        }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
