//
//  ProviderPreferences.swift
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

public final class ProviderPreferences: ObservableObject, ProviderPreferencesRepository {
    private var repository: ProviderPreferencesRepository?

    public init() {
    }

    public func setRepository(_ repository: ProviderPreferencesRepository?) {
        self.repository = repository
    }

    public func favoriteServers() -> ObservableList<String> {
        ObservableList { [weak self] in
            self?.isFavoriteServer($0) ?? false
        } add: { [weak self] in
            self?.addFavoriteServer($0)
        } remove: { [weak self] in
            self?.removeFavoriteServer($0)
        }
    }

    public func isFavoriteServer(_ serverId: String) -> Bool {
        repository?.isFavoriteServer(serverId) ?? false
    }

    public func addFavoriteServer(_ serverId: String) {
        objectWillChange.send()
        repository?.addFavoriteServer(serverId)
    }

    public func removeFavoriteServer(_ serverId: String) {
        objectWillChange.send()
        repository?.removeFavoriteServer(serverId)
    }

    public func save() throws {
        try repository?.save()
    }
}
