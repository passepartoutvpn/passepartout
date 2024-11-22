//
//  ProfilePreview.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/22/24.
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

public struct ProfilePreview: Identifiable, Hashable {
    public let id: Profile.ID

    public let name: String

    public let subtitle: String?

    public init(id: Profile.ID, name: String, subtitle: String? = nil) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
    }

    public init(_ profile: Profile) {
        id = profile.id
        name = profile.name
        subtitle = nil
    }
}
