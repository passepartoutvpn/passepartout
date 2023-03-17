//
//  ProfileItemGroup.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/3/22.
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
import AppKit

struct ProfileItemGroup: ItemGroup {
    private let profileManager: LightProfileManager

    private let providerManager: LightProviderManager

    private let vpnManager: LightVPNManager

    init(profileManager: LightProfileManager, providerManager: LightProviderManager, vpnManager: LightVPNManager) {
        self.profileManager = profileManager
        self.providerManager = providerManager
        self.vpnManager = vpnManager
    }

    func asMenuItems(withParent parent: NSMenu) -> [NSMenuItem] {
        profileManager.profiles.map {
            $0.isProvider ? providerItem(withProfile: $0, parent: parent) : hostItem(withProfile: $0, parent: parent)
        }
    }

    private func hostItem(withProfile profile: LightProfile, parent: NSMenu) -> NSMenuItem {
        HostProfileItem(profile, vpnManager: vpnManager)
            .asMenuItem(withParent: parent)
    }

    private func providerItem(withProfile profile: LightProfile, parent: NSMenu) -> NSMenuItem {
        ProviderProfileItem(profile, providerManager: providerManager, vpnManager: vpnManager)
            .asMenuItem(withParent: parent)
    }
}
