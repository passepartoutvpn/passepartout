//
//  SceneDelegate.swift
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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func sceneDidEnterBackground(_ scene: UIScene) {
        #if targetEnvironment(macCatalyst)
        MacBundle.shared.utils.sendAppToBackground()
        #endif
        rebuildShortcutItems()
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcutItem(shortcutItem)
    }
}

private extension SceneDelegate {
    enum ShortcutType: String {
        case enableVPN

        case disableVPN

        case reconnectVPN
    }

    func rebuildShortcutItems() {
        let items: [UIApplicationShortcutItem]
        if VPNManager.shared.currentState.isEnabled {
            let toggleItem = UIApplicationShortcutItem(
                type: ShortcutType.disableVPN.rawValue,
                localizedTitle: L10n.Shortcuts.Add.Items.DisableVpn.caption
            )
            let reconnectItem = UIApplicationShortcutItem(
                type: ShortcutType.reconnectVPN.rawValue,
                localizedTitle: L10n.Global.Strings.reconnect
            )
            items = [toggleItem, reconnectItem]
        } else if ProfileManager.shared.hasActiveProfile {
            let toggleItem = UIApplicationShortcutItem(
                type: ShortcutType.enableVPN.rawValue,
                localizedTitle: L10n.Shortcuts.Add.Items.EnableVpn.caption
            )
            items = [toggleItem]
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
