//
//  App+iOS.swift
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

import AppAccessibility
import AppLibraryMain
import SwiftUI

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configure(with: AppLibraryMain())
        return true
    }
}

extension PassepartoutApp {
    var body: some Scene {
        WindowGroup {
            contentView()
                .onLoad {
                    context.appearanceManager.apply()
                }
                .task(id: scenePhase) {
                    if scenePhase == .active {
                        context.onApplicationActive()
                    }
                }
                .onOpenURL { url in
                    AppPipe.importer.send([url])
                }
                .themeLockScreen()
                .withEnvironment(from: context, theme: theme)
                .environment(\.isUITesting, AppCommandLine.contains(.uiTesting))
                .tint(.accentColor)
        }
    }
}
