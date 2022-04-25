//
//  ProfileView+Buttons.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/25/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

import SwiftUI
import PassepartoutCore

extension ProfileView {
    struct RemoveProfileButton: View {
        @ObservedObject private var profileManager: ProfileManager
        
        private let header: Profile.Header
        
        @State private var isConfirming = false
        
        private let title = L10n.Organizer.Alerts.RemoveProfile.title
        
        init(header: Profile.Header) {
            profileManager = .shared
            self.header = header
        }

        var body: some View {
            DestructiveButton {
                isConfirming = true
            } label: {
                Label(title, systemImage: themeDeleteImage)
            }.actionSheet(isPresented: $isConfirming) {
                ActionSheet(
                    title: Text(L10n.Organizer.Alerts.RemoveProfile.message(header.name)),
                    message: nil,
                    buttons: [
                        .destructive(Text(title), action: removeProfile),
                        .cancel(Text(L10n.Global.Strings.cancel))
                    ]
                )
            }.themeDestructiveButtonStyle()
        }

        private func removeProfile() {
            profileManager.removeProfiles(withIds: [header.id])
        }
    }

    struct UninstallVPNButton: View {
        @ObservedObject private var vpnManager: VPNManager
        
        @State private var isConfirming = false
        
        init() {
            vpnManager = .shared
        }
        
        var body: some View {
            DestructiveButton {
                isConfirming = true
            } label: {
                Label(L10n.Profile.Items.Uninstall.caption, systemImage: themeDeleteImage)
            }.actionSheet(isPresented: $isConfirming) {
                ActionSheet(
                    title: Text(L10n.Profile.Alerts.UninstallVpn.message),
                    message: nil,
                    buttons: [
                        .destructive(Text(L10n.Profile.Items.Uninstall.caption), action: uninstallVPN),
                        .cancel(Text(L10n.Global.Strings.cancel))
                    ]
                )
            }.themeDestructiveButtonStyle()
        }
        
        private func uninstallVPN() {
            Task {
                await vpnManager.uninstall()
            }
        }
    }
}
