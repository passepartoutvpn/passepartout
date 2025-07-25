//
//  ProfileEditor.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import Combine
import CommonLibrary
import Foundation

@MainActor
public final class ProfileEditor: ObservableObject {

    @Published
    var editableProfile: EditableProfile

    @Published
    public var isShared: Bool

    var removedModules: [UUID: any ModuleBuilder]

    public convenience init() {
        self.init(modules: [])
    }

    // for testing/previews
    public init(profile: Profile) {
        editableProfile = profile.editable()
        isShared = false
        removedModules = [:]
    }

    // for testing/previews
    public init(modules: [any ModuleBuilder]) {
        editableProfile = EditableProfile(
            modules: modules,
            activeModulesIds: Set(modules.map(\.id))
        )
        isShared = false
        removedModules = [:]
    }
}

// MARK: - Types

extension ProfileEditor {
    public var moduleTypes: [ModuleType] {
        editableProfile.modules
            .map(\.moduleType)
    }

    public func availableModuleTypes(forTarget target: DistributionTarget) -> [ModuleType] {
        let types: [ModuleType]
        if target.supportsPaidFeatures {
            types = ModuleType.allCases
        } else {
            types = [.onDemand, .openVPN, .wireGuard]
        }
        return types
            .filter {
                !moduleTypes.contains($0)
            }
    }
}

// MARK: - Editing

extension ProfileEditor {
    public var profile: EditableProfile {
        get {
            editableProfile
        }
        set {
            editableProfile = newValue
        }
    }

    public var keepsAliveOnSleep: Bool {
        get {
            !editableProfile.disconnectsOnSleep
        }
        set {
            var behavior = editableProfile.behavior ?? ProfileBehavior()
            behavior.disconnectsOnSleep = !newValue
            editableProfile.behavior = behavior
        }
    }

    public var isAvailableForTV: Bool {
        get {
            editableProfile.attributes.isAvailableForTV == true
        }
        set {
            editableProfile.attributes.isAvailableForTV = newValue
        }
    }
}

extension ProfileEditor {
    public var modules: [any ModuleBuilder] {
        editableProfile.modules
    }

    public var activeModules: [any ModuleBuilder] {
        editableProfile.modules.filter {
            isActiveModule(withId: $0.id)
        }
    }

    public func module(withId moduleId: UUID) -> (any ModuleBuilder)? {
        editableProfile.modules.first {
            $0.id == moduleId
        } ?? removedModules[moduleId]
    }

    public func isActiveModule(withId moduleId: UUID) -> Bool {
        editableProfile.isActiveModule(withId: moduleId)
    }

    public func toggleModule(withId moduleId: UUID) {
        guard let existingModule = module(withId: moduleId) else {
            return
        }
        if isActiveModule(withId: moduleId) {
            editableProfile.activeModulesIds.remove(moduleId)
        } else {
            activateModule(existingModule)
        }
    }

    public func moveModules(from offsets: IndexSet, to newOffset: Int) {
        editableProfile.modules.move(fromOffsets: offsets, toOffset: newOffset)
    }

    public func removeModules(at offsets: IndexSet) {
        offsets.forEach {
            let module = editableProfile.modules[$0]
            removedModules[module.id] = module
            editableProfile.modules.remove(at: $0)
        }
    }

    public func removeModule(withId moduleId: UUID) {
        guard let index = editableProfile.modules.firstIndex(where: { $0.id == moduleId }) else {
            return
        }
        let module = editableProfile.modules[index]
        removedModules[module.id] = module
        editableProfile.modules.remove(at: index)
    }

    public func saveModule(_ module: any ModuleBuilder, activating: Bool) {
        if let index = editableProfile.modules.firstIndex(where: { $0.id == module.id }) {
            editableProfile.modules[index] = module
        } else {
            editableProfile.modules.append(module)
        }
        if activating {
            activateModule(module)
        }
    }

    public func discard() {
    }
}

private extension ProfileEditor {
    func activateModule(_ module: any ModuleBuilder) {
        editableProfile.activeModulesIds.insert(module.id)
    }
}

// MARK: - Building

extension ProfileEditor {
    public func build() throws -> Profile {
        try build(with: nil)
    }

    public func build(with registry: Registry?) throws -> Profile {

        // add this check in the app, the library does not enforce it
        guard !editableProfile.activeModulesIds.isEmpty else {
            throw PartoutError(.noActiveModules)
        }

        // validate builders if implementation supports it
        try editableProfile.modules.forEach {
            guard let impl = registry?.implementation(for: $0) as? ModuleBuilderValidator else {
                return
            }
            do {
                try impl.validate($0)
            } catch {
                throw AppError.malformedModule($0, error: error)
            }
        }

        let builder = try editableProfile.builder()
        let profile = try builder.tryBuild()

        // update local view
        editableProfile.modules = profile.modulesBuilders()

        return profile
    }
}

// MARK: - Testing

extension ProfileEditor {
    var activeModulesIds: Set<UUID> {
        editableProfile.activeModulesIds
    }
}
