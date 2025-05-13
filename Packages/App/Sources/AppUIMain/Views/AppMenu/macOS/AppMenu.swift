//
//  AppMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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

#if os(macOS)

import Combine
import CommonLibrary
import CommonUtils
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
        showButton
        loginToggle
        keepToggle
        Divider()
        Group {
            reconnectButton
            disconnectButton
        }
        .disabled(!isTunnelActionable)
        if profileManager.hasProfiles {
            Divider()
            profilesList
        }
        Divider()
        aboutButton
        quitButton
    }
}

private extension AppMenu {
    var versionItem: some View {
        Text(BundleConfiguration.mainVersionString)
    }

    var showButton: some View {
        Button(Strings.Global.Actions.show) {
            showApp()
        }
    }

    var loginToggle: some View {
        Toggle(Strings.Views.Preferences.launchesOnLogin, isOn: $settings.launchesOnLogin)
    }

    var keepToggle: some View {
        Toggle(Strings.Views.Preferences.keepsInMenu, isOn: $settings.keepsInMenu)
    }

    var reconnectButton: some View {
        Button(Strings.Global.Actions.reconnect, action: reconnect)
    }

    var disconnectButton: some View {
        Button(Strings.Global.Actions.disconnect, action: disconnect)
    }

    var profilesList: some View {
        ForEach(profileManager.previews, id: \.id, content: profileToggle)
            .themeSection(header: Strings.Views.App.Folders.default)
    }

    func profileToggle(for preview: ProfilePreview) -> some View {
        Toggle(preview.name, isOn: profileToggleBinding(for: preview))
    }

    func profileToggleBinding(for preview: ProfilePreview) -> Binding<Bool> {
        Binding {
            isProfileActive(preview)
        } set: { isOn in
            toggleProfile(isOn, for: preview)
        }
    }

    var aboutButton: some View {
        Button(Strings.Global.Nouns.about, action: openAbout)
    }

    var quitButton: some View {
        Button(Strings.Views.AppMenu.Items.quit(BundleConfiguration.mainDisplayName), action: quit)
    }
}

private extension AppMenu {
    var isTunnelActionable: Bool {
        // FIXME: #218, must be per-tunnel
        [.activating, .active].contains(tunnelStatus)
    }

    func showApp(completion: (() -> Void)? = nil) {
        Task {
            do {
                try await AppWindow.shared.show()
                completion?()
            } catch {
                pp_log(.app, .error, "Unable to launch app: \(error)")
            }
        }
    }

    func reconnect() {
        Task {
            // FIXME: #218, must be per-tunnel
//            guard let activeProfileId = tunnel.activeProfile?.id else {
            guard let installedProfile else {
                return
            }
            guard let profile = profileManager.profile(withId: installedProfile.id) else {
                return
            }
            do {
                try await tunnel.disconnect(from: installedProfile.id)
                try await tunnel.connect(with: profile)
            } catch {
                pp_log(.app, .error, "Unable to reconnect to profile \(profile.id) from menu: \(error)")
            }
        }
    }

    func disconnect() {
        Task {
            do {
                // FIXME: #218, must be per-tunnel
                guard let installedProfile else {
                    return
                }
                try await tunnel.disconnect(from: installedProfile.id)
            } catch {
                pp_log(.app, .error, "Unable to disconnect from menu: \(error)")
            }
        }
    }

    func isProfileActive(_ preview: ProfilePreview) -> Bool {
        tunnel.status(ofProfileId: preview.id) != .inactive
    }

    func toggleProfile(_ isOn: Bool, for preview: ProfilePreview) {
        Task {
            guard let profile = profileManager.profile(withId: preview.id) else {
                return
            }
            do {
                if isOn {
                    try await tunnel.connect(with: profile)
                } else {
                    try await tunnel.disconnect(from: profile.id)
                }
            } catch {
                pp_log(.app, .error, "Unable to toggle profile \(preview.id) from menu: \(error)")
            }
        }
    }

    func openAbout() {
        showApp {
            NSApp.orderFrontStandardAboutPanel(self)
        }
    }

    func quit() {
        NSApp.terminate(self)
    }
}

private extension AppMenu {

    // FIXME: #218, must be per-tunnel
    var tunnelStatus: TunnelStatus {
        installedProfile?.status ?? .inactive
    }

    // FIXME: #218, must be per-tunnel
    var installedProfile: TunnelActiveProfile? {
        tunnel.activeProfiles.first?.value
    }
}

#endif
