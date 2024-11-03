//
//  ProviderFavoriteServers.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/25/24.
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

import SwiftUI

public struct ProviderFavoriteServers {
    private var map: [UUID: Set<String>]

    public init() {
        map = [:]
    }

    public func servers(forModuleWithId moduleId: UUID) -> Set<String> {
        map[moduleId] ?? []
    }

    public mutating func setServers(_ servers: Set<String>, forModuleWithId moduleId: UUID) {
        map[moduleId] = servers
    }
}

extension ProviderFavoriteServers: RawRepresentable {
    public var rawValue: String {
        (try? JSONEncoder().encode(map))?.base64EncodedString() ?? ""
    }

    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            return nil
        }
        map = (try? JSONDecoder().decode([UUID: Set<String>].self, from: data)) ?? [:]
    }
}
