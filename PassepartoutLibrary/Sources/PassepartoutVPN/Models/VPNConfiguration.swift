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
import TunnelKitManager
import NetworkExtension
import PassepartoutCore

public typealias VPNConfiguration = (neConfiguration: NetworkExtensionConfiguration, neExtra: NetworkExtensionExtra)

protocol VPNConfigurationProviding {
    func vpnConfiguration(_ parameters: VPNConfigurationParameters) throws -> VPNConfiguration
}

struct VPNConfigurationParameters {
    let title: String

    let appGroup: String

    let preferences: VPNPreferences

    let networkSettings: Profile.NetworkSettings

    let username: String?

    let passwordReference: Data?

    let withNetworkSettings: Bool

    let onDemandRules: [NEOnDemandRule]

    init(
        _ profile: Profile,
        appGroup: String,
        preferences: VPNPreferences,
        passwordReference: Data?,
        withNetworkSettings: Bool,
        withCustomRules: Bool
    ) {
        title = profile.header.name
        self.appGroup = appGroup
        self.preferences = preferences
        networkSettings = profile.networkSettings
        username = !profile.account.username.isEmpty ? profile.account.username : nil
        self.passwordReference = passwordReference
        self.withNetworkSettings = withNetworkSettings
        onDemandRules = profile.onDemandRules(withCustomRules: withCustomRules)
    }
}
