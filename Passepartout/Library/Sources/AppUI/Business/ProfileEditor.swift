//
//  ProfileEditor.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

import AppLibrary
import Combine
import CommonLibrary
import Foundation
import PassepartoutKit

@MainActor
final class ProfileEditor: ObservableObject {
    private(set) var id: Profile.ID

    @Published
    var name: String

    @Published
    var isShared: Bool

    @Published
    private(set) var modules: [any EditableModule]

    @Published
    private(set) var activeModulesIds: Set<UUID>

    @Published
    private var moduleNames: [UUID: String]

    private(set) var removedModules: [UUID: any EditableModule]

    convenience init() {
        self.init(modules: [])
    }

    init(modules: [any EditableModule]) {
        id = UUID()
        name = ""
        self.modules = modules
        activeModulesIds = Set(modules.map(\.id))
        moduleNames = [:]
        removedModules = [:]
        isShared = false
    }

    init(profile: Profile) {
        id = profile.id
        name = profile.name
        modules = profile.modulesBuilders
        activeModulesIds = profile.activeModulesIds
        moduleNames = profile.moduleNames
        removedModules = [:]
        isShared = false
    }

    func editProfile(_ profile: Profile, isShared: Bool) {
        id = profile.id
        name = profile.name
        modules = profile.modulesBuilders
        activeModulesIds = profile.activeModulesIds
        moduleNames = profile.moduleNames
        removedModules = [:]
        self.isShared = isShared
    }
}

// MARK: - CRUD

extension ProfileEditor {
    var moduleTypes: [ModuleType] {
        modules
            .compactMap {
                $0 as? ModuleTypeProviding
            }
            .map(\.moduleType)
    }

    var availableModuleTypes: [ModuleType] {
        ModuleType
            .allCases
            .filter {
                // TODO: #657, hide manual OpenVPN/WireGuard until editable
                $0 != .openVPN && $0 != .wireGuard
            }
            .filter {
                !moduleTypes.contains($0)
            }
            .sorted {
                $0.localizedDescription < $1.localizedDescription
            }
    }

    func displayName(forModuleWithId moduleId: UUID) -> String? {
        guard let name = moduleNames[moduleId] else {
            return nil
        }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty ? trimmedName : nil
    }

    func name(forModuleWithId moduleId: UUID) -> String? {
        moduleNames[moduleId]
    }

    func setName(_ name: String, forModuleWithId moduleId: UUID) {
        moduleNames[moduleId] = name
    }

    func module(withId moduleId: UUID) -> (any EditableModule)? {
        modules.first {
            $0.id == moduleId
        } ?? removedModules[moduleId]
    }

    func moveModules(from offsets: IndexSet, to newOffset: Int) {
        modules.move(fromOffsets: offsets, toOffset: newOffset)
    }

    func removeModules(at offsets: IndexSet) {
        offsets.forEach {
            let module = modules[$0]
            removedModules[module.id] = module
            modules.remove(at: $0)
        }
    }

    func removeModule(withId moduleId: UUID) {
        guard let index = modules.firstIndex(where: { $0.id == moduleId }) else {
            return
        }
        let module = modules[index]
        removedModules[module.id] = module
        modules.remove(at: index)
    }

    func saveModule(_ module: any EditableModule, activating: Bool) {
        if let index = modules.firstIndex(where: { $0.id == module.id }) {
            modules[index] = module
        } else {
            modules.append(module)
        }
        if activating {
            activateModule(module)
        }
    }
}

// MARK: - Active modules

extension ProfileEditor {
    func isActiveModule(withId moduleId: UUID) -> Bool {
        activeModulesIds.contains(moduleId) && !removedModules.keys.contains(moduleId)
    }

    var activeConnectionModule: (any EditableModule)? {
        modules.first {
            isActiveModule(withId: $0.id) && $0.buildsConnectionModule
        }
    }

    var activeModules: [any EditableModule] {
        modules.filter {
            activeModulesIds.contains($0.id)
        }
    }

    func activateModule(_ module: any EditableModule) {
        activeModulesIds.insert(module.id)
    }

    func toggleModule(withId moduleId: UUID) {
        guard let existingModule = module(withId: moduleId) else {
            return
        }
        if isActiveModule(withId: moduleId) {
            activeModulesIds.remove(moduleId)
        } else {
            activateModule(existingModule)
        }
    }
}

private extension ProfileEditor {
    func checkConstraints() throws {
        if activeConnectionModule == nil,
           let ipModule = modules.first(where: { activeModulesIds.contains($0.id) && $0 is IPModule.Builder }) {
            throw AppError.ipModuleRequiresConnection(ipModule)
        }

        let connectionModules = modules.filter {
            activeModulesIds.contains($0.id) && $0.buildsConnectionModule
        }
        guard connectionModules.count <= 1 else {
            throw AppError.multipleConnectionModules(connectionModules)
        }
    }
}

// MARK: - Building

extension ProfileEditor {
    func build() throws -> Profile {
        try checkConstraints()

        var builder = Profile.Builder(id: id)
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw AppError.emptyProfileName
        }
        builder.name = trimmedName
        builder.modules = try modules.compactMap {
            do {
                return try $0.tryBuild()
            } catch {
                throw AppError.malformedModule($0, error: error)
            }
        }
        builder.activeModulesIds = activeModulesIds
        builder.moduleNames = moduleNames.reduce(into: [:]) {
            let trimmedName = $1.value.trimmingCharacters(in: .whitespaces)
            guard !trimmedName.isEmpty else {
                return
            }
            $0[$1.key] = trimmedName
        }
        let profile = try builder.tryBuild()

        // update local view
        modules = profile.modulesBuilders
        removedModules.removeAll()

        return profile
    }
}

private extension Profile {
    var modulesBuilders: [any EditableModule] {
        modules.compactMap {
            guard let buildableModule = $0 as? any BuildableType else {
                return nil
            }
            let builder = buildableModule.builder() as any BuilderType
            return builder as? any EditableModule
        }
    }
}

// MARK: - Saving

extension ProfileEditor {
    func save(to profileManager: ProfileManager) async throws {
        do {
            let newProfile = try build()
            try await profileManager.save(newProfile)
            try await profileManager.setRemotelyShared(isShared, profileWithId: newProfile.id)
        } catch {
            pp_log(.app, .fault, "Unable to save edited profile: \(error)")
            throw error
        }
    }
}
