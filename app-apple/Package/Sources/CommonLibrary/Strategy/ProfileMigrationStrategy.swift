// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

public protocol ProfileMigrationStrategy {
    var hasMigratableProfiles: Bool { get}

    func fetchMigratableProfiles() async throws -> [MigratableProfile]

    func fetchProfile(withId profileId: UUID) async throws -> Profile?

    func deleteProfiles(withIds profileIds: Set<UUID>) async throws
}
