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

import AppLibrary
import PassepartoutKit
import SwiftUI

// FIXME: #788, UI for Apple TV

public struct AppCoordinator: View, AppCoordinatorConforming {
    private let profileManager: ProfileManager

    private let tunnel: ExtendedTunnel

    private let registry: Registry

    public init(profileManager: ProfileManager, connectionObserver: ExtendedTunnel, registry: Registry) {
        self.profileManager = profileManager
        self.connectionObserver = connectionObserver
        self.registry = registry
    }

    public var body: some View {
        ProfilesView(profileManager: profileManager)
    }
}

struct ProfilesView: View {

    @ObservedObject
    var profileManager: ProfileManager

    var body: some View {
        ForEach(profileManager.headers, id: \.id) {
            Text($0.name)
        }
    }
}
