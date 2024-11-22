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

    @EnvironmentObject
    private var settings: MacSettingsModel

    @ObservedObject
    private var profileManager: ProfileManager

    @ObservedObject
    private var tunnel: ExtendedTunnel

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
            settings.isVisible = true
        }
    }

    var loginToggle: some View {
        Toggle(Strings.Views.Settings.launchesOnLogin, isOn: $settings.launchesOnLogin)
    }

    var keepToggle: some View {
        Toggle(Strings.Views.Settings.keepsInMenu, isOn: $settings.keepsInMenu)
    }

    var profilesList: some View {
        ForEach(profileManager.previews, id: \.id, content: profileToggle)
    }

    func profileToggle(for preview: ProfilePreview) -> some View {
        Toggle(preview.name, isOn: profileToggleBinding(for: preview))
    }

    func profileToggleBinding(for preview: ProfilePreview) -> Binding<Bool> {
        Binding {
            preview.id == tunnel.currentProfile?.id && tunnel.status != .inactive
        } set: { isOn in
            Task {
                guard let profile = profileManager.profile(withId: preview.id) else {
                    return
                }
                do {
                    if isOn {
                        try await tunnel.connect(with: profile)
                    } else {
                        try await tunnel.disconnect()
                    }
                } catch {
                    pp_log(.app, .error, "Unable to toggle profile \(preview.id) from menu: \(error)")
                }
            }
        }
    }

    var aboutButton: some View {
        Button(Strings.Global.about.withTrailingDots) {
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
