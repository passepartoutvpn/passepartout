//
//  CDModulePreferencesRepositoryV3.swift
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
    public static func cdModulePreferencesRepositoryV3(context: NSManagedObjectContext, moduleId: UUID) throws -> ModulePreferencesRepository {
        try CDModulePreferencesRepositoryV3(context: context, moduleId: moduleId)
    }
}

private final class CDModulePreferencesRepositoryV3: ModulePreferencesRepository {
    private nonisolated let context: NSManagedObjectContext

    private let entity: CDModulePreferencesV3

    init(context: NSManagedObjectContext, moduleId: UUID) throws {
        self.context = context

        entity = try context.performAndWait {
            let request = CDModulePreferencesV3.fetchRequest()
            request.predicate = NSPredicate(format: "uuid == %@", moduleId.uuidString)
            do {
                let entity = try request.execute().first ?? CDModulePreferencesV3(context: context)
                entity.uuid = moduleId
                return entity
            } catch {
                pp_log(.app, .error, "Unable to load preferences for module \(moduleId): \(error)")
                throw error
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
            cdEndpoint.modulePreferences = entity
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

    func discard() {
        context.rollback()
    }
}
