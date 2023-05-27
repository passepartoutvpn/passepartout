//
//  VPNConfigurationParameters.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/22/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import PassepartoutCore

public struct VPNConfigurationParameters {
    public let profile: Profile

    public var title: String {
        profile.header.name
    }

    public let preferences: VPNPreferences

    public var networkSettings: Profile.NetworkSettings {
        profile.networkSettings
    }

    public var username: String? {
        !profile.account.username.isEmpty ? profile.account.username : nil
    }

    public let passwordReference: Data?

    public let withNetworkSettings: Bool

    public let withCustomRules: Bool

    init(
        _ profile: Profile,
        preferences: VPNPreferences,
        passwordReference: Data?,
        withNetworkSettings: Bool,
        withCustomRules: Bool
    ) {
        self.profile = profile
        self.preferences = preferences
        self.passwordReference = passwordReference
        self.withNetworkSettings = withNetworkSettings
        self.withCustomRules = withCustomRules
    }
}
