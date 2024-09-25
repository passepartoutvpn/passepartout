//
//  PassepartoutApp.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/22/24.
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

import AppUI
import CommonLibrary
import PassepartoutKit
import SwiftUI

@main
struct PassepartoutApp: App {

#if os(iOS)
    @UIApplicationDelegateAdaptor
    private var appDelegate: AppDelegate
#else
    @NSApplicationDelegateAdaptor
    private var appDelegate: AppDelegate
#endif

    private let context: AppContext = .shared
//    private let context: AppContext = .mock(withRegistry: .shared)

    @StateObject
    private var theme = Theme()

    var body: some Scene {
        WindowGroup {
            AppCoordinator(
                profileManager: context.profileManager,
                tunnel: context.tunnel,
                registry: context.registry
            )
            .onLoad {
                CommonLibrary.configureLogging(
                    to: Constants.shared.urlForAppLog,
                    parameters: Constants.shared.log
                )
                AppUI.configure(with: context)
            }
            .themeLockScreen()
            .environmentObject(theme)
            .environmentObject(context.iapManager)
            .environmentObject(context.connectionObserver)
        }
#if os(macOS)
        .defaultSize(width: 600.0, height: 400.0)
#endif
    }
}
