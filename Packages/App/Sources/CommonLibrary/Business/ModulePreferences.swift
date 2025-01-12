//
//  ModulePreferences.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/10/24.
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

public final class ModulePreferences: ObservableObject, ModulePreferencesRepository {
    private var repository: ModulePreferencesRepository?

    public init() {
    }

    public func setRepository(_ repository: ModulePreferencesRepository?) {
        self.repository = repository
    }

    public func isExcludedEndpoint(_ endpoint: ExtendedEndpoint) -> Bool {
        repository?.isExcludedEndpoint(endpoint) ?? false
    }

    public func addExcludedEndpoint(_ endpoint: ExtendedEndpoint) {
        objectWillChange.send()
        repository?.addExcludedEndpoint(endpoint)
    }

    public func removeExcludedEndpoint(_ endpoint: ExtendedEndpoint) {
        objectWillChange.send()
        repository?.removeExcludedEndpoint(endpoint)
    }

    public func erase() {
        repository?.erase()
    }

    public func save() throws {
        try repository?.save()
    }
}
