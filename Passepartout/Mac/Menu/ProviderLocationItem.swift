//
//  ProviderLocationItem.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/12/22.
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

struct ProviderLocationItem: Item {
    private let profile: LightProfile

    private let location: LightProviderLocation

    private let vpnManager: LightVPNManager

    init(_ profile: LightProfile, _ location: LightProviderLocation, vpnManager: LightVPNManager) {
        self.profile = profile
        self.location = location
        self.vpnManager = vpnManager
    }

    func asMenuItem(withParent parent: NSMenu) -> NSMenuItem {
        let viewModel = ViewModel(profile, location, vpnManager: vpnManager)
        let item = NSMenuItem(
            title: viewModel.location.description,
            action: nil,
            keyEquivalent: ""
        )
        item.image = viewModel.location.nsImage
        item.state = viewModel.isActiveLocation ? .on : .off
        item.representedObject = viewModel

        if viewModel.isOnlyServer {
            item.target = viewModel
            item.action = #selector(viewModel.connectTo)
        } else {
            let submenu = NSMenu()
            location.servers.forEach {
                submenu.addItem(serverItem(with: $0, parent: submenu))
            }
            item.submenu = submenu
        }

        return item
    }

    private func serverItem(with server: LightProviderServer, parent: NSMenu) -> NSMenuItem {
        ProviderServerItem(profile, server, vpnManager: vpnManager)
            .asMenuItem(withParent: parent)
    }
}
