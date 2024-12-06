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

@MainActor
public final class PreferencesManager: ObservableObject {
    private let modulesRepository: ModulePreferencesRepository

    private let providersRepository: ProviderPreferencesRepository

    public init(
        modulesRepository: ModulePreferencesRepository? = nil,
        providersRepository: ProviderPreferencesRepository? = nil
    ) {
        self.modulesRepository = modulesRepository ?? DummyModulePreferencesRepository()
        self.providersRepository = providersRepository ?? DummyProviderPreferencesRepository()
    }

    public func modulePreferencesProxy(in moduleId: UUID) throws -> ModulePreferencesProxy {
        try modulesRepository.modulePreferencesProxy(in: moduleId)
    }

    public func providerPreferencesProxy(in providerId: ProviderID) throws -> ProviderPreferencesProxy {
        try providersRepository.providerPreferencesProxy(in: providerId)
    }
}

// MARK: - Dummy

private final class DummyModulePreferencesRepository: ModulePreferencesRepository {
    private final class Proxy: ModulePreferencesProxy {
        func save() throws {
        }
    }

    func modulePreferencesProxy(in moduleId: UUID) throws -> ModulePreferencesProxy {
        Proxy()
    }
}

private final class DummyProviderPreferencesRepository: ProviderPreferencesRepository {
    private final class Proxy: ProviderPreferencesProxy {
        var favoriteServers: Set<String> = []

        func save() throws {
        }
    }

    func providerPreferencesProxy(in providerId: ProviderID) throws -> ProviderPreferencesProxy {
        Proxy()
    }
}
