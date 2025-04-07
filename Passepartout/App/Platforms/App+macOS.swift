//
//  App+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import AppUIMain
import Combine
import CommonLibrary
import CommonUtils
import Partout
import SwiftUI
import UIAccessibility

extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        configure(with: AppUIMain())
        context.onApplicationActive()
        if settings.isStartedFromLoginItem {
            AppWindow.shared.isVisible = false
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        AppWindow.shared.isVisible = false
        return !settings.keepsInMenu
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        AppPipe.importer.send(urls)
    }
}

extension PassepartoutApp {

    @SceneBuilder
    var body: some Scene {
        Window(appName, id: appName) {
            contentView()
                .onReceive(didActivateNotificationPublisher) {
                    context.onApplicationActive()
                }
                .withEnvironment(from: context, theme: theme)
                .environmentObject(settings)
                .environment(\.isUITesting, AppCommandLine.contains(.uiTesting))
                .frame(minWidth: 600, minHeight: 400)
        }
        .defaultSize(width: 600, height: 400)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(Strings.Global.Nouns.settings) {
                    Task {
                        try await AppWindow.shared.show()
                        AppPipe.settings.send()
                    }
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        MenuBarExtra {
            AppMenu(
                profileManager: context.profileManager,
                tunnel: context.tunnel
            )
            .withEnvironment(from: context, theme: theme)
            .environmentObject(settings)
            .environment(\.isUITesting, AppCommandLine.contains(.uiTesting))
        } label: {
            AppMenuImage(tunnel: context.tunnel)
                .environmentObject(theme)
        }
    }
}

private extension PassepartoutApp {
    var didActivateNotificationPublisher: AnyPublisher<Void, Never> {
        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.didActivateApplicationNotification)
            .map {
                guard let app = $0.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
                    return false
                }
                return app.bundleIdentifier == Bundle.main.bundleIdentifier
            }
            .removeDuplicates()
            .filter { $0 }
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
