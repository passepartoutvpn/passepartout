//
//  ProfileView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/6/22.
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

import PassepartoutLibrary
import SwiftUI

struct ProfileView: View {
    enum ModalType: Int, Identifiable {
        case interactiveAccount

        #if !os(tvOS)
        case shortcuts
        #endif

        case rename

        case paywallShortcuts

        case paywallNetworkSettings

        case paywallTrustedNetworks

        case paywallAppleTV

        var id: Int {
            rawValue
        }
    }

    @ObservedObject private var currentProfile: ObservableProfile

    @State private var modalType: ModalType?

    init() {
        currentProfile = ProfileManager.shared.currentProfile
    }

    var body: some View {
        debugChanges()
        return Group {
            if isLoading || isExisting {
                mainView
            } else {
                WelcomeView()
            }
        }.toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if themeIdiom != .phone {
                    SettingsButton()
                }
                MainMenu(
                    currentProfile: currentProfile,
                    modalType: $modalType
                ).disabled(!isExisting)
            }
        }.sheet(item: $modalType, content: presentedModal)
        .navigationTitle(title)
        .themeSecondaryView()
    }
}

// MARK: -

private extension ProfileView {
    var isLoading: Bool {
        currentProfile.isLoading
    }

    var isExisting: Bool {
        !currentProfile.value.isPlaceholder
    }

    var title: String {
        currentProfile.name
    }

    var mainView: some View {
        List {
            if !isLoading {
                VPNSection(
                    profile: currentProfile.value,
                    modalType: $modalType
                )
                ProviderSection(currentProfile: currentProfile)
                ConfigurationSection(
                    currentProfile: currentProfile,
                    modalType: $modalType
                )
                TVSection(
                    currentProfile: currentProfile,
                    modalType: $modalType
                )
                ExtraSection(currentProfile: currentProfile)
                Section {
                    DiagnosticsRow(currentProfile: currentProfile)
                }
            } else {
                ProgressView()
            }
        }.themeAnimation(on: isLoading)
    }

    @ViewBuilder
    func presentedModal(_ modalType: ModalType) -> some View {
        switch modalType {
        case .interactiveAccount:
            NavigationView {
                InteractiveConnectionView(profile: currentProfile.value)
            }.themeGlobal()

        #if !os(tvOS)
        case .shortcuts:
            NavigationView {
                ShortcutsView(target: currentProfile.value)
            }.themeGlobal()
        #endif

        case .rename:
            NavigationView {
                RenameView(currentProfile: currentProfile)
            }.themeGlobal()

        case .paywallShortcuts:
            NavigationView {
                PaywallView(
                    modalType: $modalType,
                    feature: .siriShortcuts
                )
            }.themeGlobal()

        case .paywallNetworkSettings:
            NavigationView {
                PaywallView(
                    modalType: $modalType,
                    feature: .networkSettings
                )
            }.themeGlobal()

        case .paywallTrustedNetworks:
            NavigationView {
                PaywallView(
                    modalType: $modalType,
                    feature: .trustedNetworks
                )
            }.themeGlobal()

        case .paywallAppleTV:
            NavigationView {
                PaywallView(
                    modalType: $modalType,
                    feature: .appleTV
                )
            }.themeGlobal()
        }
    }
}
