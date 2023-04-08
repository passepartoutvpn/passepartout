//
//  PassepartoutMenu.swift
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

@MainActor
class PassepartoutMenu {
    private let macMenuDelegate: MacMenuDelegate

    private let profileManager: LightProfileManager

    private let providerManager: LightProviderManager

    private let statusButton: StatusButton

    init(macMenuDelegate: MacMenuDelegate) {
        self.macMenuDelegate = macMenuDelegate
        profileManager = macMenuDelegate.profileManager
        providerManager = macMenuDelegate.providerManager
        statusButton = StatusButton(
            profileManager: profileManager,
            vpnManager: macMenuDelegate.vpnManager
        )

        profileManager.delegate = self
        providerManager.delegate = self

    }

    func install() {
        statusButton.install(systemMenu: StaticSystemMenu(body))
    }

    private var body: [ItemGroup] {
        var children: [ItemGroup] = []

        children.append(contentsOf: [
            TextItem(Constants.Global.appVersionString),
            SeparatorItem()
        ] as [ItemGroup])

        children.append(contentsOf: [
            VisibilityItem(
                L10n.Global.Strings.show,
                utils: macMenuDelegate.utils
            ),
            LaunchOnLoginItem(
                L10n.Preferences.Items.LaunchesOnLogin.caption,
                utils: macMenuDelegate.utils
            )
        ] as [ItemGroup])

        if profileManager.hasProfiles {
            children.append(contentsOf: [
                SeparatorItem(),
                ProfileItemGroup(
                    profileManager: macMenuDelegate.profileManager,
                    providerManager: macMenuDelegate.providerManager,
                    vpnManager: macMenuDelegate.vpnManager
                )
            ] as [ItemGroup])
        }

        if profileManager.activeProfileId != nil {
            children.append(contentsOf: [
                SeparatorItem(),
                VPNItemGroup(
                    vpnManager: macMenuDelegate.vpnManager
                ) {
                    $0 ? L10n.Profile.Items.Vpn.TurnOff.caption : L10n.Profile.Items.Vpn.TurnOn.caption
                } reconnectTitleBlock: {
                    L10n.Global.Strings.reconnect
                }
            ] as [ItemGroup])
        }

        children.append(contentsOf: [
            SeparatorItem(),
//            TextItem(L10n.Menu.All.About.title(Constants.Global.appName)) {
//
//                // this does not work when app is in background
//                NSApp.orderFrontStandardAboutPanel(nil)
//                NSApp.activate(ignoringOtherApps: true)
//            },
            TextItem(L10n.Menu.System.Quit.title(Constants.Global.appName), key: "q") {
                NSApp.terminate(nil)
            }
        ] as [ItemGroup])

        return children
    }
}

extension PassepartoutMenu: LightProfileManagerDelegate {
    func didUpdateProfiles() {
        install()
    }
}

extension PassepartoutMenu: LightProviderManagerDelegate {
    func didUpdateProviders() {
        install()
    }
}
