//
//  App+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

#if os(macOS)

import AppUIMain
import CommonLibrary
import PassepartoutKit
import SwiftUI

extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        configure(with: AppUIMain(isStartedFromLoginItem: isStartedFromLoginItem))
        hideIfLoginItem()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        AppWindow.shared.isVisible = false
        return !keepsInMenu
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        ImporterPipe.shared.send(urls)
    }
}

private extension AppDelegate {
    var keepsInMenu: Bool {
        get {
            UserDefaults.standard.bool(forKey: AppPreference.keepsInMenu.key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppPreference.keepsInMenu.key)
        }
    }

    var isStartedFromLoginItem: Bool {
        NSApp.isHidden
    }

    func hideIfLoginItem() {
        if isStartedFromLoginItem {
            AppWindow.shared.isVisible = false
        }
    }
}

extension PassepartoutApp {

    @SceneBuilder
    var body: some Scene {
        Window(appName, id: appName) {
            contentView()
                .withEnvironment(from: context, theme: theme)
        }
        .defaultSize(width: 600, height: 400)

        Settings {
            SettingsView(profileManager: context.profileManager)
                .frame(minWidth: 300, minHeight: 200)
                .withEnvironment(from: context, theme: theme)
        }
        MenuBarExtra {
            AppMenu(
                profileManager: context.profileManager,
                tunnel: context.tunnel
            )
            .withEnvironment(from: context, theme: theme)
        } label: {
            AppMenuImage(tunnel: context.tunnel)
                .environmentObject(theme)
        }
    }
}

#endif
