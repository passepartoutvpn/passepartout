//
//  AppMenu.swift
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

#if os(macOS)

import AppLibrary
import Combine
import PassepartoutKit
import SwiftUI

public struct AppMenu: View {

    @EnvironmentObject
    private var profileManager: ProfileManager

    @EnvironmentObject
    private var profileProcessor: ProfileProcessor

    @EnvironmentObject
    private var tunnel: Tunnel

    @StateObject
    private var model = Model()

    public init() {
    }

    public var body: some View {
        versionItem
        Divider()
        dockToggle
        loginToggle
        Divider()
        profilesList
        Divider()
        quitButton
    }
}

private extension AppMenu {
    var versionItem: some View {
        Text(BundleConfiguration.mainVersionString)
    }

    var dockToggle: some View {
        Button(model.isVisible ? Strings.Global.hide : Strings.Global.show) {
            model.isVisible.toggle()
            if !model.isVisible {
                AppWindow.shared.close()
            }
        }
    }

    var loginToggle: some View {
        Toggle(Strings.AppMenu.Items.launchOnLogin, isOn: $model.launchesOnLogin)
    }

    var profilesList: some View {
        ForEach(profileManager.headers, id: \.id, content: profileToggle)
    }

    func profileToggle(for header: ProfileHeader) -> some View {
        Toggle(header.name, isOn: profileToggleBinding(for: header))
    }

    func profileToggleBinding(for header: ProfileHeader) -> Binding<Bool> {
        Binding {
            header.id == tunnel.currentProfile?.id && tunnel.status != .inactive
        } set: { isOn in
            Task {
                guard let profile = profileManager.profile(withId: header.id) else {
                    return
                }
                do {
                    if isOn {
                        try await tunnel.connect(with: profile, processor: profileProcessor)
                    } else {
                        try await tunnel.disconnect()
                    }
                } catch {
                    pp_log(.app, .error, "Unable to toggle profile \(header.id) from menu: \(error)")
                }
            }
        }
    }

    var quitButton: some View {
        Button(Strings.AppMenu.Items.quit(BundleConfiguration.mainDisplayName)) {
            NSApp.terminate(self)
        }
    }
}

#endif
