//
//  ProfileEditor+UI.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/28/24.
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
import CommonUtils
import PassepartoutKit
import SwiftUI

extension ProfileEditor {
    public subscript<T>(module: T) -> Binding<T> where T: ModuleBuilder {
        Binding { [weak self] in
            guard let foundModule = self?.module(withId: module.id) else {
                fatalError("Module not found in editor: \(module.id)")
            }
            guard let matchingModule = foundModule as? T else {
                fatalError("Type mismatch when binding to editor module: \(type(of: foundModule)) != \(type(of: module))")
            }
            return matchingModule
        } set: { [weak self] in
            self?.saveModule($0, activating: false)
        }
    }
}

// MARK: - ModulePreferences

extension ProfileEditor {
    public func excludedEndpoints(for moduleId: UUID, modulePreferences: ModulePreferences) -> ObservableList<ExtendedEndpoint> {
        ObservableList { [weak self] endpoint in
            self?.profile.attributes.preference(inModule: moduleId) {
                $0.isExcludedEndpoint(endpoint)
            } ?? false
        } add: { [weak self] endpoint in
            self?.profile.attributes.editPreferences(inModule: moduleId) {
                $0.addExcludedEndpoint(endpoint)
            }
            modulePreferences.addExcludedEndpoint(endpoint)
        } remove: { [weak self] endpoint in
            self?.profile.attributes.editPreferences(inModule: moduleId) {
                $0.removeExcludedEndpoint(endpoint)
            }
            modulePreferences.removeExcludedEndpoint(endpoint)
        }
    }
}
