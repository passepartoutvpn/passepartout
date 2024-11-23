//
//  ProfileV2MigrationStrategy.swift
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
import CommonUtils
import Foundation
import PassepartoutKit

public final class ProfileV2MigrationStrategy: ProfileMigrationStrategy, Sendable {
    public struct Container {
        public let name: String

        public let cloudKitIdentifier: String?

        public init(_ name: String, _ cloudKitIdentifier: String?) {
            self.name = name
            self.cloudKitIdentifier = cloudKitIdentifier
        }
    }

    private let profilesRepository: CDProfileRepositoryV2

    private let tvProfilesRepository: CDProfileRepositoryV2

    public init(
        coreDataLogger: CoreDataPersistentStoreLogger?,
        baseURL: URL? = nil,
        profilesContainer: Container,
        tvProfilesContainer: Container
    ) {
        let store = CoreDataPersistentStore(
            logger: coreDataLogger,
            containerName: profilesContainer.name,
            baseURL: baseURL,
            model: CDProfileRepositoryV2.model,
            cloudKitIdentifier: profilesContainer.cloudKitIdentifier,
            author: nil
        )
        let tvStore = CoreDataPersistentStore(
            logger: coreDataLogger,
            containerName: tvProfilesContainer.name,
            baseURL: baseURL,
            model: CDProfileRepositoryV2.model,
            cloudKitIdentifier: tvProfilesContainer.cloudKitIdentifier,
            author: nil
        )
        profilesRepository = CDProfileRepositoryV2(context: store.backgroundContext)
        tvProfilesRepository = CDProfileRepositoryV2(context: tvStore.backgroundContext)
    }
}

// MARK: - ProfileMigrationStrategy

extension ProfileV2MigrationStrategy {
    public func fetchMigratableProfiles() async throws -> [MigratableProfile] {
        try await profilesRepository.migratableProfiles()
    }

    public func fetchProfile(withId profileId: UUID) async throws -> Profile? {
        let mapper = MapperV2()
        do {
            guard let profile = try await profilesRepository.profile(withId: profileId) else {
                return nil
            }
            let tvProfile = try? await tvProfilesRepository.profile(withId: profileId)
            return try mapper.toProfileV3(profile, isTV: tvProfile != nil)
        } catch {
            pp_log(.App.migration, .error, "Unable to fetch and map migratable profile \(profileId): \(error)")
            return nil
        }
    }

    public func deleteProfiles(withIds profileIds: Set<UUID>) async throws {
        try await profilesRepository.deleteProfiles(withIds: profileIds)
    }
}

// MARK: - Internal

extension ProfileV2MigrationStrategy {
    func fetchProfilesV2() async throws -> [ProfileV2] {
        try await profilesRepository.profiles(withIds: nil)
    }
}
