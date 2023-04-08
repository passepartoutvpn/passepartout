//
//  AppDelegate.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/25/22.
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
import UIKit
import PassepartoutLibrary

class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    private let mac = MacBundle.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if targetEnvironment(macCatalyst)
        mac.configure()
        mac.menu.install()
        if mac.utils.isStartedByLauncher {
            mac.utils.sendAppToBackground()
        }
        #endif
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "SceneDelegate", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        builder.remove(menu: .file)
        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
        builder.remove(menu: .view)
        builder.remove(menu: .help)
    }
}
