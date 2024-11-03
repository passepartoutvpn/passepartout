//
//  AppCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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

import CommonLibrary
import PassepartoutKit
import SwiftUI

public struct AppCoordinator: View, AppCoordinatorConforming {
    private let profileManager: ProfileManager

    private let tunnel: ExtendedTunnel

    private let registry: Registry

    public init(profileManager: ProfileManager, tunnel: ExtendedTunnel, registry: Registry) {
        self.profileManager = profileManager
        self.tunnel = tunnel
        self.registry = registry
    }

    public var body: some View {
        debugChanges()
        return TabView {
            profileView
                .tabItem {
                    Text(Strings.Global.profile)
                }

//            searchView
//                .tabItem {
//                    ThemeImage(.search)
//                }

            settingsView
                .tabItem {
                    ThemeImage(.settings)
                }
        }
    }
}

private extension AppCoordinator {
    var profileView: some View {
        ProfileView(profileManager: profileManager, tunnel: tunnel)
    }

//    var searchView: some View {
//        VStack {
//            Text("Search")
//        }
//    }

    // FIXME: #788, UI for TV
    var settingsView: some View {
        VStack {
            Text("Settings")
        }
    }
}
