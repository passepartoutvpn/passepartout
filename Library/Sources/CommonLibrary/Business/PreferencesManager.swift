//
//  PreferencesManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/4/24.
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

import CommonUtils
import Foundation
import PassepartoutKit

public final class PreferencesManager: ObservableObject {
    private let modulesRepository: ModulePreferencesRepository

    private let providersFactory: (ProviderID) throws -> ProviderPreferencesRepository

    public init(
        modulesRepository: ModulePreferencesRepository? = nil,
        providersFactory: ((ProviderID) throws -> ProviderPreferencesRepository)? = nil
    ) {
        self.modulesRepository = modulesRepository ?? DummyModulePreferencesRepository()
        self.providersFactory = providersFactory ?? { _ in
            DummyProviderPreferencesRepository()
        }
    }

    public func preferences(forProfile profile: Profile) throws -> [UUID: ModulePreferences] {
        try preferences(forModulesWithIds: profile.modules.map(\.id))
    }

    public func preferences(forProfile editableProfile: EditableProfile) throws -> [UUID: ModulePreferences] {
        try preferences(forModulesWithIds: editableProfile.modules.map(\.id))
    }

    public func saveModulesPreferences(_ preferences: [UUID: ModulePreferences]) throws {
        try modulesRepository.set(preferences)
    }

    public func preferences(forProviderWithId providerId: ProviderID) throws -> ProviderPreferencesRepository {
        try providersFactory(providerId)
    }
}

private extension PreferencesManager {
    func preferences(forModulesWithIds moduleIds: [UUID]) throws -> [UUID: ModulePreferences] {
        try modulesRepository.preferences(for: moduleIds)
    }
}

// MARK: - Dummy

private final class DummyModulePreferencesRepository: ModulePreferencesRepository {
    func preferences(for moduleIds: [UUID]) throws -> [UUID: ModulePreferences] {
        [:]
    }

    func set(_ preferences: [UUID: ModulePreferences]) throws {
    }
}

private final class DummyProviderPreferencesRepository: ProviderPreferencesRepository {
    var favoriteServers: Set<String> = []

    func save() throws {
    }
}
