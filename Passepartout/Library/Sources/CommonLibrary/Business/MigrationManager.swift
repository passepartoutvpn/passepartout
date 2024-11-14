//
//  MigrationManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/13/24.
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

import Foundation
import PassepartoutKit

@MainActor
public final class MigrationManager: ObservableObject {
    public struct Simulation {
        public let maxMigrationTime: Double?

        public let randomFailures: Bool

        public init(maxMigrationTime: Double?, randomFailures: Bool) {
            self.maxMigrationTime = maxMigrationTime
            self.randomFailures = randomFailures
        }
    }

    private let profileStrategy: ProfileMigrationStrategy

    private nonisolated let simulation: Simulation?

    public convenience init(profileStrategy: ProfileMigrationStrategy? = nil) {
        self.init(profileStrategy: profileStrategy, simulation: nil)
    }

    public init(profileStrategy: ProfileMigrationStrategy? = nil, simulation: Simulation?) {
        self.profileStrategy = profileStrategy ?? DummyProfileStrategy()
        self.simulation = simulation
    }
}

extension MigrationManager {
    public func fetchMigratableProfiles() async throws -> [MigratableProfile] {
        try await profileStrategy.fetchMigratableProfiles()
    }

    public func migrateProfile(withId profileId: UUID) async throws -> Profile? {
        try await profileStrategy.fetchProfile(withId: profileId)
    }

    public func migrateProfiles(
        _ profiles: [MigratableProfile],
        selection: Set<UUID>,
        onUpdate: @escaping @MainActor (UUID, MigrationStatus) -> Void
    ) async throws -> [Profile] {
        profiles.forEach {
            onUpdate($0.id, selection.contains($0.id) ? .pending : .excluded)
        }
        return try await withThrowingTaskGroup(of: Profile?.self, returning: [Profile].self) { group in
            selection.forEach { profileId in
                group.addTask {
                    do {
                        if let simulation = self.simulation {
                            if let maxMigrationTime = simulation.maxMigrationTime {
                                try await Task.sleep(for: .seconds(.random(in: 1.0..<maxMigrationTime)))
                            }
                            if simulation.randomFailures, Bool.random() {
                                throw PassepartoutError(.unhandled)
                            }
                        }
                        guard let profile = try await self.profileStrategy.fetchProfile(withId: profileId) else {
                            await onUpdate(profileId, .failed)
                            return nil
                        }
                        await onUpdate(profileId, .migrated)
                        return profile
                    } catch {
                        await onUpdate(profileId, .failed)
                        return nil
                    }
                }
            }
            var profiles: [Profile] = []
            for try await profile in group {
                guard let profile else {
                    continue
                }
                profiles.append(profile)
            }
            return profiles
        }
    }
}

// MARK: - Dummy

private final class DummyProfileStrategy: ProfileMigrationStrategy {
    public init() {
    }

    public func fetchMigratableProfiles() async throws -> [MigratableProfile] {
        []
    }

    func fetchProfile(withId profileId: UUID) async throws -> Profile? {
        nil
    }
}
