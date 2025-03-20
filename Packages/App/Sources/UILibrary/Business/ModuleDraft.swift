//
//  ModuleDraft.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/7/25.
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

import Foundation
import PassepartoutKit

@MainActor
public final class ModuleDraft<T>: ObservableObject where T: ModuleBuilder {
    private weak var editor: ProfileEditor?

    private let staticEditor: ProfileEditor?

    private let moduleId: UUID

    public var module: T {
        get {
            guard let editor else {
                fatalError("Editor is nil")
            }
            guard let foundModule = editor.module(withId: moduleId) else {
//                fatalError("Module not found in editor: \(moduleId)")
                return T.empty()
            }
            guard let matchingModule = foundModule as? T else {
                fatalError("Type mismatch when binding to editor module: \(type(of: foundModule)) != \(T.self)")
            }
            return matchingModule
        }
        set {
            objectWillChange.send()
            editor?.saveModule(newValue, activating: false)
        }
    }

    public init(module: T) {
        staticEditor = ProfileEditor(modules: [module])
        editor = staticEditor
        moduleId = module.id
    }

    init(editor: ProfileEditor, module: T) {
        self.editor = editor
        staticEditor = nil
        moduleId = module.id
    }
}
