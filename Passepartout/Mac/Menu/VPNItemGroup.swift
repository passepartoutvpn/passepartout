//
//  VPNToggleItem.swift
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

struct VPNItemGroup: ItemGroup {
    private let viewModel: ViewModel

    init(
        vpnManager: LightVPNManager,
        toggleTitleBlock: @escaping (Bool) -> String,
        reconnectTitleBlock: @escaping () -> String
    ) {
        viewModel = ViewModel(
            vpnManager: vpnManager,
            toggleTitleBlock: toggleTitleBlock,
            reconnectTitleBlock: reconnectTitleBlock
        )
    }

    func asMenuItems(withParent parent: NSMenu) -> [NSMenuItem] {
        [
            toggleItem(withParent: parent),
            reconnectItem(withParent: parent)
        ]
    }

    private func toggleItem(withParent parent: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(
            title: viewModel.toggleTitle,
            action: #selector(viewModel.toggleVPN),
            keyEquivalent: ""
        )
        item.target = viewModel
        item.representedObject = viewModel

        viewModel.subscribeVPNState { _, _ in
            item.title = viewModel.toggleTitle
        }
        return item
    }

    private func reconnectItem(withParent parent: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(
            title: viewModel.reconnectTitle,
            action: #selector(viewModel.reconnectVPN),
            keyEquivalent: ""
        )
        item.target = viewModel
        item.representedObject = viewModel
        return item
    }
}
