//
//  HostProfileItem.swift
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

struct HostProfileItem: Item {
    private let viewModel: ViewModel

    init(_ profile: LightProfile, vpnManager: LightVPNManager) {
        viewModel = ViewModel(profile, vpnManager: vpnManager)
    }

    func asMenuItem(withParent parent: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(
            title: viewModel.profile.name,
            action: nil,
            keyEquivalent: ""
        )
        item.state = viewModel.profile.isActive ? .on : .off
        item.submenu = submenu()
        item.representedObject = viewModel
        return item
    }

    private func submenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let toggleItem = NSMenuItem()
        toggleItem.target = viewModel
        toggleItem.representedObject = viewModel

        viewModel.subscribe {
            if $0 == .disconnected {
                toggleItem.title = L10n.Global.Strings.connect
                toggleItem.action = #selector(viewModel.connectTo)
            } else {
                toggleItem.title = L10n.Global.Strings.disconnect
                toggleItem.action = #selector(viewModel.disconnect)
            }
        }

        menu.addItem(toggleItem)
        return menu
    }
}
