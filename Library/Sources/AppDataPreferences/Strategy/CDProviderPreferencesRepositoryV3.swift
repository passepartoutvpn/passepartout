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
    public static func cdProviderPreferencesRepositoryV3(context: NSManagedObjectContext, providerId: ProviderID) throws -> ProviderPreferencesRepository {
        try CDProviderPreferencesRepositoryV3(context: context, providerId: providerId)
    }
}

private final class CDProviderPreferencesRepositoryV3: ProviderPreferencesRepository {
    private nonisolated let context: NSManagedObjectContext

    private let entity: CDProviderPreferencesV3

    init(context: NSManagedObjectContext, providerId: ProviderID) throws {
        self.context = context

        entity = try context.performAndWait {
            let request = CDProviderPreferencesV3.fetchRequest()
            request.predicate = NSPredicate(format: "providerId == %@", providerId.rawValue)
            request.sortDescriptors = [.init(key: "lastUpdate", ascending: false)]
            do {
                let entities = try request.execute()

                // dedup by lastUpdate
                entities.enumerated().forEach {
                    guard $0.offset > 0 else {
                        return
                    }
                    $0.element.excludedEndpoints?.forEach(context.delete(_:))
                    context.delete($0.element)
                }

                let entity = entities.first ?? CDProviderPreferencesV3(context: context)
                entity.providerId = providerId.rawValue
                entity.lastUpdate = Date()
                return entity
            } catch {
                pp_log(.app, .error, "Unable to load preferences for provider \(providerId): \(error)")
                throw error
            }
        }
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

    func isExcludedEndpoint(_ endpoint: ExtendedEndpoint) -> Bool {
        context.performAndWait {
            entity.excludedEndpoints?.contains {
                $0.endpoint == endpoint.rawValue
            } ?? false
        }
    }

    func addExcludedEndpoint(_ endpoint: ExtendedEndpoint) {
        context.performAndWait {
            let mapper = CoreDataMapper(context: context)
            let cdEndpoint = mapper.cdExcludedEndpoint(from: endpoint)
            cdEndpoint.providerPreferences = entity
            entity.excludedEndpoints?.insert(cdEndpoint)
        }
    }

    func removeExcludedEndpoint(_ endpoint: ExtendedEndpoint) {
        context.performAndWait {
            guard let found = entity.excludedEndpoints?.first(where: {
                $0.endpoint == endpoint.rawValue
            }) else {
                return
            }
            entity.excludedEndpoints?.remove(found)
            context.delete(found)
        }
    }

    func save() throws {
        try context.performAndWait {
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
}
