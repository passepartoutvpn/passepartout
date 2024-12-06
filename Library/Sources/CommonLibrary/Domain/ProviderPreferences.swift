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

import Foundation
import PassepartoutKit

@MainActor
public final class ProviderPreferences: ObservableObject {
    public var proxy: ProviderPreferencesProxy? {
        didSet {
            objectWillChange.send()
        }
    }

    public init(proxy: ProviderPreferencesProxy?) {
        self.proxy = proxy
    }

    public var favoriteServers: Set<String> {
        get {
            proxy?.favoriteServers ?? []
        }
        set {
            objectWillChange.send()
            proxy?.favoriteServers = newValue
        }
    }

    public func save() throws {
        try proxy?.save()
    }
}

@MainActor
public protocol ProviderPreferencesProxy {
    var favoriteServers: Set<String> { get set }

    func save() throws
}
