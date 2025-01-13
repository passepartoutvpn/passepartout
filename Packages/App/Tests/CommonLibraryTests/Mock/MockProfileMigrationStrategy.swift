//
//  MockProfileMigrationStrategy.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/21/24.
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
import Foundation
import PassepartoutKit

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
