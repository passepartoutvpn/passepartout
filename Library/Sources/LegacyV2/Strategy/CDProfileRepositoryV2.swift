//
//  CDProfileRepositoryV2.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/1/24.
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

import CommonLibrary
@preconcurrency import CoreData
import Foundation
import PassepartoutKit

final class CDProfileRepositoryV2: Sendable {
    static var model: NSManagedObjectModel {
        guard let model: NSManagedObjectModel = .mergedModel(from: [.module]) else {
            fatalError("Unable to build Core Data model (Profiles v2)")
        }
        return model
    }

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    var hasMigratableProfiles: Bool {
        do {
            return try context.performAndWait {
                let entities = try CDProfile.fetchRequest().execute()
                return !entities.compactMap {
                    ($0.encryptedJSON ?? $0.json) != nil
                }.isEmpty
            }
        } catch {
            return false
        }
    }

    func migratableProfiles() async throws -> [MigratableProfile] {
        try await fetchProfiles(
            prefetch: {
                $0.propertiesToFetch = ["uuid", "name", "lastUpdate"]
            },
            map: {
                $0.compactMap {
                    guard ($0.value.encryptedJSON ?? $0.value.json) != nil else {
                        pp_log(.App.migration, .error, "ProfileV2 \($0.key) is not migratable: missing JSON")
                        return nil
                    }
                    return MigratableProfile(
                        id: $0.key,
                        name: $0.value.name ?? $0.key.uuidString,
                        lastUpdate: $0.value.lastUpdate
                    )
                }
            }
        )
    }

    func profile(withId profileId: UUID) async throws -> ProfileV2? {
        try await profiles(withIds: [profileId]).first
    }

    func profiles(withIds profileIds: Set<UUID>?) async throws -> [ProfileV2] {
        let decoder = JSONDecoder()
        let profiles: [ProfileV2] = try await fetchProfiles(
            prefetch: {
                if let profileIds {
                    $0.predicate = NSPredicate(format: "any uuid in %@", profileIds)
                }
            },
            map: {
                $0.compactMap {
                    guard let json = $0.value.encryptedJSON ?? $0.value.json else {
                        pp_log(.App.migration, .error, "ProfileV2 \($0.key) is not migratable: missing JSON")
                        return nil
                    }
                    do {
                        return try decoder.decode(ProfileV2.self, from: json)
                    } catch {
                        pp_log(.App.migration, .error, "Unable to decode ProfileV2 \($0.key): \(error)")
                        return nil
                    }
                }
            }
        )
        return profiles
    }

    func deleteProfiles(withIds profileIds: Set<UUID>) async throws {
        try await context.perform { [weak self] in
            guard let self else {
                return
            }
            let request = CDProfile.fetchRequest()
            request.predicate = NSPredicate(format: "any uuid in %@", profileIds)
            let existing = try context.fetch(request)
            existing.forEach(context.delete)
            try context.save()
        }
    }
}

extension CDProfileRepositoryV2 {
    func fetchProfiles<T>(
        prefetch: ((NSFetchRequest<CDProfile>) -> Void)? = nil,
        map: @escaping ([UUID: CDProfile]) -> [T]
    ) async throws -> [T] {
        try await context.perform { [weak self] in
            guard let self else {
                return []
            }

            let request = CDProfile.fetchRequest()
            request.sortDescriptors = [
                .init(key: "lastUpdate", ascending: false)
            ]
            prefetch?(request)
            let existing = try context.fetch(request)

            var deduped: [UUID: CDProfile] = [:]
            existing.forEach {
                guard let uuid = $0.uuid else {
                    return
                }
                guard !deduped.keys.contains(uuid) else {
                    pp_log(.App.migration, .info, "Skip older duplicate of ProfileV2 \(uuid)")
                    return
                }
                deduped[uuid] = $0
            }

            return map(deduped)
        }
    }
}
