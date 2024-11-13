//
//  LegacyManager.swift
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

public protocol LegacyStrategy {
    func fetchMigratableProfiles() async throws -> [MigratableProfile]

    func fetchProfiles(selection: Set<UUID>) async throws -> (migrated: [Profile], failed: Set<UUID>)
}

@MainActor
public final class LegacyManager: ObservableObject {
    private let strategy: LegacyStrategy

    public init(strategy: LegacyStrategy = EmptyStrategy()) {
        self.strategy = strategy
    }
}

extension LegacyManager: LegacyStrategy {
    public func fetchMigratableProfiles() async throws -> [MigratableProfile] {
        try await strategy.fetchMigratableProfiles()
    }

    public func fetchProfiles(selection: Set<UUID>) async throws -> (migrated: [Profile], failed: Set<UUID>) {
        try await strategy.fetchProfiles(selection: selection)
    }
}

extension LegacyManager {
    public final class EmptyStrategy: LegacyStrategy {
        public init() {
        }

        public func fetchMigratableProfiles() async throws -> [MigratableProfile] {
            []
        }

        public func fetchProfiles(selection: Set<UUID>) async throws -> (migrated: [Profile], failed: Set<UUID>) {
            ([], [])
        }
    }
}
