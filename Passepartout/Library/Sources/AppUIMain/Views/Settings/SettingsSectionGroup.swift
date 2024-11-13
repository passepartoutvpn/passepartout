//
//  SettingsSectionGroup.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/3/24.
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
import CommonUtils
import PassepartoutKit
import SwiftUI

struct SettingsSectionGroup: View {
    let profileManager: ProfileManager

#if os(iOS)
    @AppStorage(AppPreference.locksInBackground.key)
    private var locksInBackground = false
#endif
#if os(macOS)
    @AppStorage(AppPreference.keepsInMenu.key)
    private var keepsInMenu = true

    @StateObject
    private var macModel = MacSettingsModel(
        appWindow: .shared,
        loginItemId: BundleConfiguration.mainString(for: .loginItemId)
    )
#endif

    @State
    private var isConfirmingEraseiCloud = false

    @State
    private var isErasingiCloud = false

    var body: some View {
#if os(iOS)
        lockInBackgroundToggle
#endif
#if os(macOS)
        launchesOnLoginToggle
        keepsInMenuToggle
#endif
        eraseCloudKitButton
    }
}

private extension SettingsSectionGroup {
#if os(iOS)
    var lockInBackgroundToggle: some View {
        Toggle(Strings.Views.Settings.locksInBackground, isOn: $locksInBackground)
            .themeSectionWithSingleRow(footer: Strings.Views.Settings.LocksInBackground.footer)
    }
#endif
#if os(macOS)
    var launchesOnLoginToggle: some View {
        Toggle(Strings.Views.Settings.launchesOnLogin, isOn: $macModel.launchesOnLogin)
            .themeSectionWithSingleRow(footer: Strings.Views.Settings.LaunchesOnLogin.footer)
    }

    var keepsInMenuToggle: some View {
        Toggle(Strings.Views.Settings.keepsInMenu, isOn: $keepsInMenu)
            .themeSectionWithSingleRow(footer: Strings.Views.Settings.KeepsInMenu.footer)
    }
#endif
    var eraseCloudKitButton: some View {
        Button(Strings.Views.Settings.eraseIcloud, role: .destructive) {
            isConfirmingEraseiCloud = true
        }
        .themeConfirmation(
            isPresented: $isConfirmingEraseiCloud,
            title: Strings.Views.Settings.eraseIcloud,
            isDestructive: true
        ) {
            isErasingiCloud = true
            Task {
                do {
                    pp_log(.app, .info, "Erase CloudKit profiles...")
                    try await profileManager.eraseRemotelySharedProfiles()
                } catch {
                    pp_log(.app, .error, "Unable to erase CloudKit store: \(error)")
                }
                isErasingiCloud = false
            }
        }
        .themeSectionWithSingleRow(
            header: Strings.Unlocalized.iCloud,
            footer: Strings.Views.Settings.EraseIcloud.footer,
            above: true
        )
        .disabled(isErasingiCloud)
    }
}
