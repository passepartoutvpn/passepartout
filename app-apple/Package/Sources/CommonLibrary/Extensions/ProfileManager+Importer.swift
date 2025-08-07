// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

extension ProfileManager: MigrationManagerImporter {
    public func importProfile(_ profile: Profile, remotelyShared: Bool) async throws {
        try await save(profile, isLocal: true, remotelyShared: remotelyShared)
    }
}
