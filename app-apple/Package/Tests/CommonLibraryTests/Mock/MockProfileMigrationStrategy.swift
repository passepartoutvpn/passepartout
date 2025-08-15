// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

final class MockProfileMigrationStrategy: ProfileMigrationStrategy {
    var migratableProfiles: [MigratableProfile] = []

    var migratedProfiles: [UUID: Profile] = [:]

    var failedProfiles: Set<UUID> = []

    var hasMigratableProfiles: Bool {
        !migratedProfiles.isEmpty
    }

    func fetchMigratableProfiles() async throws -> [MigratableProfile] {
        migratableProfiles
    }

    func fetchProfile(withId profileId: UUID) async throws -> Profile? {
        if failedProfiles.contains(profileId) {
            throw AppError.permissionDenied
        }
        return migratedProfiles[profileId]
    }

    func deleteProfiles(withIds profileIds: Set<UUID>) async throws {
        profileIds.forEach { id in
            migratableProfiles.removeAll {
                $0.id == id
            }
            migratedProfiles.removeValue(forKey: id)
        }
    }
}
