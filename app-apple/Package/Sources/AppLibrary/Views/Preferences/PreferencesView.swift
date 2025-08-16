// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

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
    private var relaxedVerification = false

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
        .themeKeyValue(kvManager, AppPreference.relaxedVerification.key, $relaxedVerification, default: false)
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
            Toggle(Strings.Views.Preferences.relaxedVerification, isOn: $relaxedVerification)
                .themeContainerEntry()
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

    @State
    private var relaxedVerification = false

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
            Toggle(Strings.Views.Preferences.relaxedVerification, isOn: $usesModernCrypto)
        }
        .themeSection(header: Strings.Views.Preferences.Experimental.header)
        .themeKeyValue(kvManager, AppPreference.usesModernCrypto.key, $usesModernCrypto, default: false)
        .themeKeyValue(kvManager, AppPreference.relaxedVerification.key, $relaxedVerification, default: false)
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
