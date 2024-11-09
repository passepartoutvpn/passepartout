//
//  CDProfileRepositoryV3.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/11/24.
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
import Combine
import CommonLibrary
import CommonUtils
import CoreData
import Foundation
import PassepartoutKit

extension AppData {
    public static func cdProfileRepositoryV3(
        registry: Registry,
        coder: ProfileCoder,
        context: NSManagedObjectContext,
        observingResults: Bool,
        onResultError: ((Error) -> CoreDataResultAction)?
    ) -> ProfileRepository {
        let repository = CoreDataRepository<CDProfileV3, Profile>(
            context: context,
            observingResults: observingResults
        ) {
            $0.sortDescriptors = [
                .init(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare)),
                .init(key: "lastUpdate", ascending: false)
            ]
        } fromMapper: {
            try fromMapper($0, registry: registry, coder: coder)
        } toMapper: {
            try toMapper($0, $1, registry: registry, coder: coder)
        } onResultError: {
            onResultError?($0) ?? .ignore
        }
        return repository
    }
}

private extension AppData {
    static func fromMapper(
        _ cdEntity: CDProfileV3,
        registry: Registry,
        coder: ProfileCoder
    ) throws -> Profile? {
        guard let encoded = cdEntity.encoded else {
            return nil
        }
        let profile = try registry.decodedProfile(from: encoded, with: coder)
        return profile
    }

    static func toMapper(
        _ profile: Profile,
        _ context: NSManagedObjectContext,
        registry: Registry,
        coder: ProfileCoder
    ) throws -> CDProfileV3 {
        let encoded = try registry.encodedProfile(profile, with: coder)

        let cdProfile = CDProfileV3(context: context)
        cdProfile.uuid = profile.id
        cdProfile.name = profile.name
        cdProfile.encoded = encoded

        // redundant but convenient
        let attributes = profile.attributes
        cdProfile.isAvailableForTV = attributes.isAvailableForTV.map(NSNumber.init(value:))
        cdProfile.lastUpdate = attributes.lastUpdate
        cdProfile.fingerprint = attributes.fingerprint

        return cdProfile
    }
}

// MARK: - Specialization

extension CDProfileV3: CoreDataUniqueEntity {
}

extension Profile: UniqueEntity {
    public var uuid: UUID? {
        id
    }
}

extension CoreDataRepository: ProfileRepository where T == Profile {
    public nonisolated var profilesPublisher: AnyPublisher<[Profile], Never> {
        entitiesPublisher
            .map(\.entities)
            .eraseToAnyPublisher()
    }

    public func saveProfile(_ profile: Profile) async throws {
        try await saveEntities([profile])
    }

    public func removeProfiles(withIds profileIds: [Profile.ID]) async throws {
        try await removeEntities(withIds: profileIds)
    }

    public func removeAllProfiles() async throws {
        try await removeEntities(withIds: nil)
    }
}
