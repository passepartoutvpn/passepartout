// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import CommonUtils
import Foundation

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
        coreDataLogger: LoggerProtocol?,
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
        profilesRepository = CDProfileRepositoryV2(context: store.backgroundContext())
        tvProfilesRepository = CDProfileRepositoryV2(context: tvStore.backgroundContext())
    }
}

// MARK: - ProfileMigrationStrategy

extension ProfileV2MigrationStrategy {
    public var hasMigratableProfiles: Bool {
        profilesRepository.hasMigratableProfiles
    }

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
            pp_log_g(.App.migration, .error, "Unable to fetch and map migratable profile \(profileId): \(error)")
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
