//
//  SceneDelegate+Shortcuts.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/19/23.
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

import SwiftUI
import PassepartoutLibrary

enum ShortcutType: String {
    case enableVPN

    case disableVPN

    case reconnectVPN
}

extension SceneDelegate {
    func rebuildShortcutItems() {
        let items: [UIApplicationShortcutItem]
        if VPNManager.shared.currentState.isEnabled {
            items = [
                ShortcutType.disableVPN.shortcutItem(withTitle: L10n.Shortcuts.Add.Items.DisableVpn.caption),
                ShortcutType.reconnectVPN.shortcutItem(withTitle: L10n.Global.Strings.reconnect)
            ]
        } else if ProfileManager.shared.hasActiveProfile {
            items = [
                ShortcutType.enableVPN.shortcutItem(withTitle: L10n.Shortcuts.Add.Items.EnableVpn.caption)
            ]
        } else {
            items = []
        }
        UIApplication.shared.shortcutItems = items
    }

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case ShortcutType.enableVPN.rawValue:
            Task {
                try await VPNManager.shared.connectWithActiveProfile(toServer: nil)
            }

        case ShortcutType.disableVPN.rawValue:
            Task {
                await VPNManager.shared.disable()
            }

        case ShortcutType.reconnectVPN.rawValue:
            Task {
                await VPNManager.shared.reconnect()
            }

        default:
            break
        }
    }
}

private extension ShortcutType {
    func shortcutItem(withTitle title: String) -> UIApplicationShortcutItem {
        UIApplicationShortcutItem(
            type: rawValue,
            localizedTitle: title,
            localizedSubtitle: nil,
            icon: .init(systemImageName: themeImageName)
        )
    }
}
