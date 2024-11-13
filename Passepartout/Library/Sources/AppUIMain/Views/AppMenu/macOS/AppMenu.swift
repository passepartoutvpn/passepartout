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

import Combine
import CommonLibrary
import PassepartoutKit
import SwiftUI

public struct AppMenu: View {

    @AppStorage(AppPreference.keepsInMenu.key)
    private var keepsInMenu = true

    @ObservedObject
    private var profileManager: ProfileManager

    @ObservedObject
    private var tunnel: ExtendedTunnel

    @StateObject
    private var model = MacSettingsModel()

    public init(profileManager: ProfileManager, tunnel: ExtendedTunnel) {
        self.profileManager = profileManager
        self.tunnel = tunnel
    }

    public var body: some View {
        versionItem
        Divider()
        showToggle
        loginToggle
        keepToggle
        Divider()
        profilesList
        Divider()
        aboutButton
        quitButton
    }
}

private extension AppMenu {
    var versionItem: some View {
        Text(BundleConfiguration.mainVersionString)
    }

    var showToggle: some View {
        Button(Strings.Global.show) {
            macModel.isVisible = true
        }
    }

    var loginToggle: some View {
        Toggle(Strings.Views.Settings.launchesOnLogin, isOn: $macModel.launchesOnLogin)
    }

    var keepToggle: some View {
        Toggle(Strings.Views.Settings.keepsInMenu, isOn: $keepsInMenu)
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
                        try await tunnel.connect(with: profile)
                    } else {
                        try await tunnel.disconnect()
                    }
                } catch {
                    pp_log(.app, .error, "Unable to toggle profile \(header.id) from menu: \(error)")
                }
            }
        }
    }

    var aboutButton: some View {
        Button("\(Strings.Global.about)...") {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.orderFrontStandardAboutPanel(self)
        }
    }

    var quitButton: some View {
        Button(Strings.AppMenu.Items.quit(BundleConfiguration.mainDisplayName)) {
            NSApp.terminate(self)
        }
    }
}

#endif
