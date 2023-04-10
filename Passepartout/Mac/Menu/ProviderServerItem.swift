//
//  ProviderServerItem.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/8/22.
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

struct ProviderServerItem: Item {
    private let profile: LightProfile

    private let server: LightProviderServer

    private let vpnManager: LightVPNManager

    init(_ profile: LightProfile, _ server: LightProviderServer, vpnManager: LightVPNManager) {
        self.profile = profile
        self.server = server
        self.vpnManager = vpnManager
    }

    func asMenuItem(withParent parent: NSMenu) -> NSMenuItem {
        let viewModel = ViewModel(profile, server, vpnManager: vpnManager)
        let item = NSMenuItem(
            title: viewModel.server.description,
            action: #selector(viewModel.connectTo),
            keyEquivalent: ""
        )
        item.target = viewModel
        item.state = viewModel.isActiveServer ? .on : .off
        item.representedObject = viewModel
        return item
    }
}
