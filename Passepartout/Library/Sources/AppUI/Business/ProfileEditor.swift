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

    @Published
    private var editable: EditableProfile

    var id: Profile.ID {
        editable.id
    }

    var name: String {
        get {
            editable.name
        }
        set {
            editable.name = newValue
        }
    }

    private(set) var modules: [any ModuleBuilder] {
        get {
            editable.modules
        }
        set {
            editable.modules = newValue
        }
    }

    private(set) var activeModulesIds: Set<UUID> {
        get {
            editable.activeModulesIds
        }
        set {
            editable.activeModulesIds = newValue
        }
    }

    private var modulesMetadata: [UUID: ModuleMetadata]? {
        get {
            editable.modulesMetadata
        }
        set {
            editable.modulesMetadata = newValue
        }
    }

    @Published
    var isShared: Bool

    private(set) var removedModules: [UUID: any ModuleBuilder]

    convenience init() {
        self.init(modules: [])
    }

    init(modules: [any ModuleBuilder]) {
        editable = EditableProfile(
            modules: modules,
            activeModulesIds: Set(modules.map(\.id))
        )
        isShared = false
        removedModules = [:]
    }

    init(profile: Profile) {
        editable = profile.editableProfile
        isShared = false
        removedModules = [:]
    }

    func editProfile(_ profile: Profile, isShared: Bool) {
        editable = profile.editableProfile
        self.isShared = isShared
        removedModules = [:]
    }
}

// MARK: - Editing

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

    func saveModule(_ module: any ModuleBuilder, activating: Bool) {
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

// MARK: - Facade

extension ProfileEditor {
    func module(withId moduleId: UUID) -> (any ModuleBuilder)? {
        editable.modules.first {
            $0.id == moduleId
        } ?? removedModules[moduleId]
    }

    func isActiveModule(withId moduleId: UUID) -> Bool {
        editable.isActiveModule(withId: moduleId)
    }

    var activeConnectionModule: (any ModuleBuilder)? {
        editable.modules.first {
            isActiveModule(withId: $0.id) && $0.buildsConnectionModule
        }
    }

    var activeModules: [any ModuleBuilder] {
        editable.modules.filter {
            editable.activeModulesIds.contains($0.id)
        }
    }

    func activateModule(_ module: any ModuleBuilder) {
        editable.activeModulesIds.insert(module.id)
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

    func displayName(forModuleWithId moduleId: UUID) -> String? {
        editable.displayName(forModuleWithId: moduleId)
    }

    func name(forModuleWithId moduleId: UUID) -> String? {
        editable.name(forModuleWithId: moduleId)
    }

    func setName(_ name: String, forModuleWithId moduleId: UUID) {
        editable.setName(name, forModuleWithId: moduleId)
    }
}

// MARK: - Building

extension ProfileEditor {
    func build() throws -> Profile {
        try checkConstraints()

        var builder = Profile.Builder(id: editable.id)
        builder.modules = try editable.modules.compactMap {
            do {
                return try $0.tryBuild()
            } catch {
                throw AppError.malformedModule($0, error: error)
            }
        }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw AppError.emptyProfileName
        }
        builder.name = trimmedName
        builder.modulesMetadata = modulesMetadata?.reduce(into: [:]) {
            var metadata = $1.value
            guard let name = metadata.name else {
                return
            }
            let trimmedName = name.trimmingCharacters(in: .whitespaces)
            guard !trimmedName.isEmpty else {
                return
            }
            metadata.name = trimmedName
            $0[$1.key] = metadata
        }
        let profile = try builder.tryBuild()

        // update local view
        editable.modules = profile.modulesBuilders
        removedModules.removeAll()

        return profile
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

// MARK: - Saving

extension ProfileEditor {
    func save(to profileManager: ProfileManager) async throws {
        do {
            let newProfile = try build()
            try await profileManager.save(newProfile, isShared: isShared)
        } catch {
            pp_log(.app, .fault, "Unable to save edited profile: \(error)")
            throw error
        }
    }
}
