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

public protocol MigrationManagerImporter {
    func importProfile(_ profile: Profile, remotelyShared: Bool) async throws
}

@MainActor
public final class MigrationManager: ObservableObject {
    public struct Simulation {
        public let fakeProfiles: Bool

        public let maxMigrationTime: Double?

        public let randomFailures: Bool

        public init(fakeProfiles: Bool, maxMigrationTime: Double?, randomFailures: Bool) {
            self.fakeProfiles = fakeProfiles
            self.maxMigrationTime = maxMigrationTime
            self.randomFailures = randomFailures
        }
    }

    private let profileStrategy: ProfileMigrationStrategy

    private nonisolated let simulation: Simulation?

    public init(
        profileStrategy: ProfileMigrationStrategy? = nil,
        simulation: Simulation? = nil
    ) {
        self.profileStrategy = profileStrategy ?? DummyProfileStrategy()
        self.simulation = simulation
    }
}

// MARK: - Public interface

extension MigrationManager {
    public func fetchMigratableProfiles() async throws -> [MigratableProfile] {
        try await profileStrategy.fetchMigratableProfiles()
    }

    public func migratedProfile(withId profileId: UUID) async throws -> Profile? {
        try await profileStrategy.fetchProfile(withId: profileId)
    }

    public func migratedProfiles(
        _ migratableProfiles: [MigratableProfile],
        onUpdate: @escaping @MainActor (UUID, MigrationStatus) -> Void
    ) async throws -> [Profile] {
        migratableProfiles.forEach {
            onUpdate($0.id, .pending)
        }
        return try await withThrowingTaskGroup(of: Profile?.self, returning: [Profile].self) { group in
            migratableProfiles.forEach { migratable in
                group.addTask {
                    do {
                        try await self.simulateBehavior()
                        guard let profile = try await self.simulateMigrateProfile(withId: migratable.id) else {
                            await onUpdate(migratable.id, .failed)
                            return nil
                        }
                        await onUpdate(migratable.id, .done)
                        return profile
                    } catch {
                        await onUpdate(migratable.id, .failed)
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

    public func importProfiles(
        _ profiles: [Profile],
        into importer: MigrationManagerImporter,
        onUpdate: @escaping @MainActor (UUID, MigrationStatus) -> Void
    ) async {
        profiles.forEach {
            onUpdate($0.id, .pending)
        }
        await withTaskGroup(of: Void.self) { group in
            profiles.forEach { profile in
                group.addTask {
                    do {
                        try await self.simulateBehavior()
                        try await self.simulateSaveProfile(profile, to: importer)
                        await onUpdate(profile.id, .done)
                    } catch {
                        await onUpdate(profile.id, .failed)
                    }
                }
            }
        }
    }

    public func deleteMigratableProfiles(withIds profileIds: Set<UUID>) async throws {
        try await simulateDeleteProfiles(withIds: profileIds)
    }
}

// MARK: - Simulation

private extension MigrationManager {
    func simulateBehavior() async throws {
        guard let simulation else {
            return
        }
        if let maxMigrationTime = simulation.maxMigrationTime {
            try await Task.sleep(for: .seconds(.random(in: 1.0..<maxMigrationTime)))
        }
        if simulation.randomFailures, Bool.random() {
            throw PassepartoutError(.unhandled)
        }
    }

    func simulateMigrateProfile(withId profileId: UUID) async throws -> Profile? {
        if simulation?.fakeProfiles ?? false {
            return try? Profile.Builder(id: profileId).tryBuild()
        }
        return try await profileStrategy.fetchProfile(withId: profileId)
    }

    func simulateSaveProfile(_ profile: Profile, to importer: MigrationManagerImporter) async throws {
        if simulation?.fakeProfiles ?? false {
            return
        }
        try await importer.importProfile(profile, remotelyShared: profile.attributes.isAvailableForTV == true)
    }

    func simulateDeleteProfiles(withIds profileIds: Set<UUID>) async throws {
        if simulation?.fakeProfiles ?? false {
            return
        }
        try await profileStrategy.deleteProfiles(withIds: profileIds)
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

    func deleteProfiles(withIds profileIds: Set<UUID>) async throws {
    }
}
