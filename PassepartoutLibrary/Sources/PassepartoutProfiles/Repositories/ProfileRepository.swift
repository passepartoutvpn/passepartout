//
//  ProfileRepository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/19/22.
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

class ProfileRepository: Repository {
    private let context: NSManagedObjectContext

    required init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchedProfiles() -> FetchedValueHolder<[UUID: Profile]> {
        let request: NSFetchRequest<NSFetchRequestResult> = CDProfile.fetchRequest()
        request.sortDescriptors = [
            .init(keyPath: \CDProfile.lastUpdate, ascending: true)
        ]
        request.propertiesToFetch = [
            "json"
        ]
        return .init(
            context: context,
            request: request,
            mapping: {
                $0.reduce(into: [UUID: Profile]()) {
                    guard let dto = $1 as? CDProfile else {
                        return
                    }
                    guard let profile = try? ProfileMapper.toModel(dto) else {
                        return
                    }
                    $0[profile.id] = profile
                }
            },
            initial: [:]
        )
    }

    func profiles() -> [Profile] {
        let request = CDProfile.fetchRequest()
        request.sortDescriptors = [
            .init(keyPath: \CDProfile.lastUpdate, ascending: true)
        ]
        do {
            let results = try context.fetch(request)
            let map = try results.reduce(into: [UUID: Profile]()) {
                guard let profile = try ProfileMapper.toModel($1) else {
                    return
                }
                $0[profile.id] = profile
            }
            return Array(map.values)
        } catch {
            pp_log.error("Unable to fetch profiles: \(error)")
            return []
        }
    }

    func profile(withId id: UUID) -> Profile? {
        let request = CDProfile.fetchRequest()
        request.predicate = NSPredicate(
            format: "uuid == %@",
            id.uuidString
        )
        request.sortDescriptors = [
            .init(keyPath: \CDProfile.lastUpdate, ascending: false)
        ]
        do {
            let results = try context.fetch(request)
            guard let recent = results.first else {
                return nil
            }
            return try ProfileMapper.toModel(recent)
        } catch {
            pp_log.error("Unable to fetch profile: \(error)")
            return nil
        }
    }

    func saveProfiles(_ profiles: [Profile]) throws {
        let request = CDProfile.fetchRequest()
        request.predicate = NSPredicate(
            format: "uuid in %@ OR name in %@", // replace with same name
            profiles.map(\.id.uuidString),
            profiles.map(\.header.name)
        )
        do {
            // dedup
            let existing = try context.fetch(request)
            existing.forEach(context.delete)

            try profiles.forEach {
                _ = try ProfileMapper(context).toDTO($0)
            }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func removeProfiles(withIds ids: [UUID]) {
        let request = CDProfile.fetchRequest()
        request.predicate = NSPredicate(
            format: "any uuid in %@",
            ids.map(\.uuidString)
        )
        do {
            try context.fetch(request).forEach {
                context.delete($0)
            }
            try context.save()
        } catch {
            pp_log.error("Unable to remove profiles: \(error)")
            context.rollback()
        }
    }
}
