//
//  LegacyV2.swift
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

public final class LegacyV2 {
    private let profilesRepository: CDProfileRepositoryV2

    private let cloudKitIdentifier: String?

    public init(
        coreDataLogger: CoreDataPersistentStoreLogger?,
        profilesContainerName: String,
        baseURL: URL,
        cloudKitIdentifier: String?
    ) {
        let store = CoreDataPersistentStore(
            logger: coreDataLogger,
            containerName: profilesContainerName,
            baseURL: baseURL,
            model: CDProfileRepositoryV2.model,
            cloudKitIdentifier: cloudKitIdentifier,
            author: nil
        )
        profilesRepository = CDProfileRepositoryV2(context: store.context)
        self.cloudKitIdentifier = cloudKitIdentifier
    }
}

// MARK: - Mapping

extension LegacyV2 {
    public func fetchMigratableProfiles() async throws -> [MigratableProfile] {
        try await profilesRepository.migratableProfiles()
    }

    public func fetchProfiles(selection: Set<UUID>) async throws -> (migrated: [Profile], failed: Set<UUID>) {
        let profilesV2 = try await profilesRepository.profiles()

        var migrated: [Profile] = []
        var failed: Set<UUID> = []
        let mapper = MapperV2()

        profilesV2.forEach {
            guard selection.contains($0.id) else {
                return
            }
            do {
                let mapped = try mapper.toProfileV3($0)
                migrated.append(mapped)
            } catch {
                pp_log(.App.migration, .error, "Unable to migrate profile \($0.id): \(error)")
                failed.insert($0.id)
            }
        }
        return (migrated, failed)
    }
}

// MARK: - Legacy profiles

extension LegacyV2 {
    func fetchProfilesV2() async throws -> [ProfileV2] {
        try await profilesRepository.profiles()
    }
}
