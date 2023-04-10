//
//  ProviderProfileItem.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/13/22.
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

struct ProviderProfileItem: Item {
    private let viewModel: ViewModel

    private let vpnManager: LightVPNManager

    init(_ profile: LightProfile, providerManager: LightProviderManager, vpnManager: LightVPNManager) {
        viewModel = ViewModel(profile, providerManager: providerManager, vpnManager: vpnManager)
        self.vpnManager = vpnManager
    }

    func asMenuItem(withParent parent: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(
            title: viewModel.profile.name,
            action: nil,
            keyEquivalent: ""
        )
        item.state = viewModel.profile.isActive ? .on : .off
        item.representedObject = viewModel
        item.submenu = submenu()
        return item
    }

    private func submenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let categories = viewModel.categories
        guard !categories.isEmpty else {
            let downloadItem = TextItem(L10n.Global.Strings.download) {
                viewModel.downloadIfNeeded()
            }
            menu.addItem(downloadItem.asMenuItem(withParent: menu))
            return menu
        }

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
        menu.addItem(.separator())

        if let currentServerDescription = viewModel.profile.providerServer?.longDescription {
            let currentItem = NSMenuItem()
            currentItem.title = currentServerDescription
            currentItem.isEnabled = false
            menu.addItem(currentItem)
        }

        if categories.count > 1 {
            viewModel.categories.forEach {
                let item = categoryItem(with: $0, parent: menu)
                item.indentationLevel = 1
                menu.addItem(item)
            }
        } else {
            viewModel.categories.first?.locations.forEach {
                let item = locationItem(with: $0, parent: menu)
                item.indentationLevel = 1
                menu.addItem(item)
            }
        }

        return menu
    }

    private func categoryItem(with category: LightProviderCategory, parent: NSMenu) -> NSMenuItem {
        let title = !category.name.isEmpty ? category.name.capitalized : L10n.Global.Strings.default
        let item = NSMenuItem(
            title: title,
            action: nil,
            keyEquivalent: ""
        )
        item.state = viewModel.isActiveCategory(category) ? .on : .off
        item.target = viewModel
        item.representedObject = viewModel

        let submenu = NSMenu()
        category.locations.forEach {
            submenu.addItem(locationItem(with: $0, parent: submenu))
        }
        item.submenu = submenu

        return item
    }

    private func locationItem(with location: LightProviderLocation, parent: NSMenu) -> NSMenuItem {
        ProviderLocationItem(viewModel.profile, location, vpnManager: vpnManager)
            .asMenuItem(withParent: parent)
    }
}
