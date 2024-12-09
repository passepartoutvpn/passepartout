//
//  ModulePreferences.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/5/24.
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
public final class ModulePreferences: ObservableObject {
    public var repository: ModulePreferencesRepository?

    public init() {
    }

    public func excludedEndpoints() -> ObservableList<ExtendedEndpoint> {
        ObservableList { [weak self] in
            self?.repository?.isExcludedEndpoint($0) == true
        } add: { [weak self] in
            self?.repository?.addExcludedEndpoint($0)
        } remove: { [weak self] in
            self?.repository?.removeExcludedEndpoint($0)
        }
    }

    public func save() throws {
        try repository?.save()
    }

    public func discard() {
        repository?.discard()
    }
}
