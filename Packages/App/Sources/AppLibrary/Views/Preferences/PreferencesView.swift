//
//  PreferencesView.swift
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
import SwiftUI

#if !os(tvOS)

public struct PreferencesView: View {

    @EnvironmentObject
    private var appearanceManager: AppearanceManager

    @EnvironmentObject
    private var iapManager: IAPManager

    @EnvironmentObject
    private var kvManager: KeyValueManager

#if os(iOS)
    @AppStorage(UIPreference.locksInBackground.key)
    private var locksInBackground = false
#elseif os(macOS)
    @EnvironmentObject
    private var settings: MacSettingsModel
#endif

    @Environment(\.distributionTarget)
    private var distributionTarget

    private let profileManager: ProfileManager

    @State
    private var dnsFallsBack = true

    @State
    private var usesModernCrypto = false

    @State
    private var isConfirmingEraseiCloud = false

    @State
    private var isErasingiCloud = false

    public init(profileManager: ProfileManager) {
        self.profileManager = profileManager
    }

    public var body: some View {
        Form {
            systemAppearanceSection
#if os(iOS)
            lockInBackgroundSection
#elseif os(macOS)
            launchesOnLoginSection
            keepsInMenuSection
#endif
            pinActiveProfileSection
            dnsFallsBackSection
            if distributionTarget.supportsIAP {
                enablesPurchasesSection
            }
            experimentalSection
            if distributionTarget.supportsCloudKit {
                eraseCloudKitSection
            }
        }
        .themeKeyValue(kvManager, AppPreference.dnsFallsBack.key, $dnsFallsBack, default: true)
        .themeKeyValue(kvManager, AppPreference.usesModernCrypto.key, $usesModernCrypto, default: false)
        .themeForm()
    }
}

private extension PreferencesView {
    static let systemAppearances: [SystemAppearance?] = [
        nil,
        .light,
        .dark
    ]

    var systemAppearanceSection: some View {
        Section {
            Picker(Strings.Views.Preferences.systemAppearance, selection: $appearanceManager.systemAppearance) {
                ForEach(Self.systemAppearances, id: \.self) {
                    Text($0?.localizedDescription ?? Strings.Entities.Ui.SystemAppearance.system)
                }
            }
        }
    }

#if os(iOS)
    var lockInBackgroundSection: some View {
        Toggle(Strings.Views.Preferences.locksInBackground, isOn: $locksInBackground)
            .themeContainerEntry(subtitle: Strings.Views.Preferences.LocksInBackground.footer)
    }

#elseif os(macOS)
    var launchesOnLoginSection: some View {
        Toggle(Strings.Views.Preferences.launchesOnLogin, isOn: $settings.launchesOnLogin)
            .themeContainerEntry(subtitle: Strings.Views.Preferences.LaunchesOnLogin.footer)
    }

    var keepsInMenuSection: some View {
        Toggle(Strings.Views.Preferences.keepsInMenu, isOn: $settings.keepsInMenu)
            .themeContainerEntry(subtitle: Strings.Views.Preferences.KeepsInMenu.footer)
    }
#endif

    var pinActiveProfileSection: some View {
        PinActiveProfileToggle()
            .themeContainerEntry(subtitle: Strings.Views.Preferences.PinsActiveProfile.footer)
    }

    var dnsFallsBackSection: some View {
        Toggle(Strings.Views.Preferences.dnsFallsBack, isOn: $dnsFallsBack)
            .themeContainerEntry(subtitle: Strings.Views.Preferences.DnsFallsBack.footer)
    }

    var enablesPurchasesSection: some View {
        Toggle(Strings.Views.Preferences.enablesIap, isOn: $iapManager.isEnabled)
            .themeContainerEntry(subtitle: Strings.Views.Preferences.EnablesIap.footer)
    }

    var experimentalSection: some View {
        Group {
            Toggle(Strings.Views.Preferences.modernCrypto, isOn: $usesModernCrypto)
                .themeContainerEntry(
                    header: Strings.Views.Preferences.Experimental.header,
                    subtitle: Strings.Views.Preferences.ModernCrypto.footer
                )
        }
        .themeContainer(header: Strings.Views.Preferences.Experimental.header)

    }

    var eraseCloudKitSection: some View {
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
                    pp_log_g(.app, .info, "Erase CloudKit profiles...")
                    try await profileManager.eraseRemotelySharedProfiles()
                } catch {
                    pp_log_g(.app, .error, "Unable to erase CloudKit store: \(error)")
                }
                isErasingiCloud = false
            }
        }
        .themeContainerWithSingleEntry(
            header: Strings.Unlocalized.iCloud,
            footer: Strings.Views.Preferences.EraseIcloud.footer,
            isAction: true
        )
        .disabled(isErasingiCloud)
    }
}

#else

public struct PreferencesView: View {

    @EnvironmentObject
    private var kvManager: KeyValueManager

    private let profileManager: ProfileManager

    @State
    private var usesModernCrypto = false

    public init(profileManager: ProfileManager) {
        self.profileManager = profileManager
    }

    public var body: some View {
        experimentalSection
    }
}

private extension PreferencesView {
    var experimentalSection: some View {
        Group {
            Toggle(Strings.Views.Preferences.modernCrypto, isOn: $usesModernCrypto)
        }
        .themeSection(header: Strings.Views.Preferences.Experimental.header)
        .themeKeyValue(kvManager, AppPreference.usesModernCrypto.key, $usesModernCrypto, default: false)
    }
}

#endif

#Preview {
    PreferencesView(profileManager: .forPreviews)
        .withMockEnvironment()
#if os(macOS)
        .environmentObject(MacSettingsModel())
#endif
}
