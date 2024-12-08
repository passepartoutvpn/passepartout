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
    public static func cdModulePreferencesRepositoryV3(context: NSManagedObjectContext) -> ModulePreferencesRepository {
        CDModulePreferencesRepositoryV3(context: context)
    }
}

private final class CDModulePreferencesRepositoryV3: ModulePreferencesRepository {
    private nonisolated let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func preferences(for moduleIds: [UUID]) throws -> [UUID: ModulePreferences] {
        try context.performAndWait {
            let request = CDModulePreferencesV3.fetchRequest()
            request.predicate = NSPredicate(format: "any uuid in %@", moduleIds.map(\.uuidString))

            let entities = try request.execute()
            let mapper = DomainMapper()
            return entities.reduce(into: [:]) {
                guard let moduleId = $1.uuid else {
                    return
                }
                do {
                    let preferences = try mapper.preferences(from: $1)
                    $0[moduleId] = preferences
                } catch {
                    pp_log(.app, .error, "Unable to load preferences for module \(moduleId): \(error)")
                }
            }
        }
    }

    func set(_ preferences: [UUID: ModulePreferences]) throws {
        try context.performAndWait {
            let request = CDModulePreferencesV3.fetchRequest()
            request.predicate = NSPredicate(format: "any uuid in %@", Array(preferences.keys))

            var entities = try request.execute()
            let existingIds = entities.compactMap(\.uuid)
            let newIds = Set(preferences.keys).subtracting(existingIds)
            newIds.forEach {
                let newEntity = CDModulePreferencesV3(context: context)
                newEntity.uuid = $0
                entities.append(newEntity)
            }

            let mapper = CoreDataMapper()
            try entities.forEach {
                guard let id = $0.uuid, let entityPreferences = preferences[id] else {
                    return
                }
                try mapper.set($0, from: entityPreferences)
            }

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

    func rollback() {
        context.rollback()
    }
}
