//
//  PreferencesGroup.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/3/24.
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

import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI

#if !os(tvOS)

public struct PreferencesGroup: View {

    @EnvironmentObject
    private var appearanceManager: AppearanceManager

#if os(iOS)
    @AppStorage(UIPreference.locksInBackground.key)
    private var locksInBackground = false
#elseif os(macOS)
    @EnvironmentObject
    private var settings: MacSettingsModel
#endif

    @AppStorage(AppPreference.dnsFallsBack.key, store: .appGroup)
    private var dnsFallsBack = true

    @AppStorage(AppPreference.skipsPurchases.key, store: .appGroup)
    private var skipsPurchases = false

    private let profileManager: ProfileManager

    @State
    private var isConfirmingEraseiCloud = false

    @State
    private var isErasingiCloud = false

    public init(profileManager: ProfileManager) {
        self.profileManager = profileManager
    }

    public var body: some View {
        systemAppearancePicker
#if os(iOS)
        lockInBackgroundToggle
#elseif os(macOS)
        launchesOnLoginToggle
        keepsInMenuToggle
#endif
        pinActiveProfileToggle
        dnsFallsBackToggle
        enablesPurchasesToggle
        eraseCloudKitButton
    }
}

private extension PreferencesGroup {
    static let systemAppearances: [SystemAppearance?] = [
        nil,
        .light,
        .dark
    ]

    var systemAppearancePicker: some View {
        Picker(Strings.Views.Preferences.systemAppearance, selection: $appearanceManager.systemAppearance) {
            ForEach(Self.systemAppearances, id: \.self) {
                Text($0?.localizedDescription ?? Strings.Entities.Ui.SystemAppearance.system)
            }
        }
    }

#if os(iOS)
    var lockInBackgroundToggle: some View {
        Toggle(Strings.Views.Preferences.locksInBackground, isOn: $locksInBackground)
            .themeSectionWithSingleRow(footer: Strings.Views.Preferences.LocksInBackground.footer)
    }
#elseif os(macOS)
    var launchesOnLoginToggle: some View {
        Toggle(Strings.Views.Preferences.launchesOnLogin, isOn: $settings.launchesOnLogin)
            .themeSectionWithSingleRow(footer: Strings.Views.Preferences.LaunchesOnLogin.footer)
    }

    var keepsInMenuToggle: some View {
        Toggle(Strings.Views.Preferences.keepsInMenu, isOn: $settings.keepsInMenu)
            .themeSectionWithSingleRow(footer: Strings.Views.Preferences.KeepsInMenu.footer)
    }
#endif

    var pinActiveProfileToggle: some View {
        PinActiveProfileToggle()
            .themeSectionWithSingleRow(footer: Strings.Views.Preferences.PinsActiveProfile.footer)
    }

    var dnsFallsBackToggle: some View {
        Toggle(Strings.Views.Preferences.dnsFallsBack, isOn: $dnsFallsBack)
            .themeSectionWithSingleRow(footer: Strings.Views.Preferences.DnsFallsBack.footer)
    }

    var enablesPurchasesToggle: some View {
        Toggle(Strings.Views.Preferences.enablesIap, isOn: enablesPurchasesBinding)
            .themeSectionWithSingleRow(footer: Strings.Views.Preferences.EnablesIap.footer)
    }

    var eraseCloudKitButton: some View {
        Button(Strings.Views.Preferences.eraseIcloud, role: .destructive) {
            isConfirmingEraseiCloud = true
        }
        .themeConfirmation(
            isPresented: $isConfirmingEraseiCloud,
            title: Strings.Views.Preferences.eraseIcloud,
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
            footer: Strings.Views.Preferences.EraseIcloud.footer,
            above: true
        )
        .disabled(isErasingiCloud)
    }
}

private extension PreferencesGroup {
    var enablesPurchasesBinding: Binding<Bool> {
        Binding {
            !skipsPurchases
        } set: {
            skipsPurchases = !$0
        }
    }
}

#endif
