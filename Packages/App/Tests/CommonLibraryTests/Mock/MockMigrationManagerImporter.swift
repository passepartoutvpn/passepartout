// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

actor MockMigrationManagerImporter: MigrationManagerImporter {
    private var failing: Set<UUID>

    private var imported: Set<Profile>

    init(failing: Set<UUID>) {
        self.failing = failing
        imported = []
    }

    func importProfile(_ profile: Profile, remotelyShared: Bool) async throws {
        guard !failing.contains(profile.id) else {
            throw AppError.permissionDenied
        }
        imported.insert(profile)
    }

    func importedProfiles() async -> Set<Profile> {
        imported
    }
}
