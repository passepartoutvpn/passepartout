//
//  ProfileView+Provider.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/18/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import PassepartoutLibrary

extension ProfileView {
    struct ProviderSection: View, ProviderProfileAvailability {
        @ObservedObject var providerManager: ProviderManager

        @ObservedObject private var currentProfile: ObservableProfile

        var profile: Profile {
            currentProfile.value
        }

        @State private var isProviderLocationPresented = false

        @State private var isRefreshingInfrastructure = false

        init(currentProfile: ObservableProfile) {
            providerManager = .shared
            self.currentProfile = currentProfile
        }

        var body: some View {
            debugChanges()
            return Group {
                if isProviderProfileAvailable {
                    mainView
                } else {
                    EmptyView()
                }
            }
        }

        @ViewBuilder
        private var mainView: some View {
            Section {
                NavigationLink(isActive: $isProviderLocationPresented) {
                    ProviderLocationView(
                        currentProfile: currentProfile,
                        isEditable: true,
                        isPresented: $isProviderLocationPresented
                    )
                } label: {
                    HStack {
                        Label(L10n.Provider.Location.title, systemImage: themeProviderLocationImage)
                        Spacer()
                        currentProviderCountryImage
                    }
                }
            } header: {
                currentProviderFullName.map(Text.init)
            } footer: {
                currentProviderServerDescription.map(Text.init)
            }
            Section {
                Toggle(
                    L10n.Profile.Items.RandomizesServer.caption,
                    isOn: $currentProfile.value.providerRandomizesServer ?? false
                )
                Toggle(
                    L10n.Profile.Items.VpnResolvesHostname.caption,
                    isOn: $currentProfile.value.networkSettings.resolvesHostname
                )
            } footer: {
                Text(L10n.Profile.Sections.VpnResolvesHostname.footer)
                    .xxxThemeTruncation()
            }
            Section {
                NavigationLink {
                    ProviderPresetView(currentProfile: currentProfile)
                } label: {
                    Label(L10n.Provider.Preset.title, systemImage: themeProviderPresetImage)
                        .withTrailingText(currentProviderPreset)
                }
                Button(action: refreshInfrastructure) {
                    Text(L10n.Profile.Items.Provider.Refresh.caption)
                }.withTrailingProgress(when: isRefreshingInfrastructure)
            } footer: {
                lastInfrastructureUpdate.map {
                    Text(L10n.Profile.Sections.ProviderInfrastructure.footer($0))
                }
            }
        }

        private var currentProviderFullName: String? {
            guard let name = profile.header.providerName else {
                assertionFailure("Provider name accessed but profile is not a provider (isPlaceholder? \(profile.isPlaceholder))")
                return nil
            }
            guard let metadata = providerManager.provider(withName: name) else {
                assertionFailure("Provider metadata not found")
                return nil
            }
            return metadata.fullName
        }

        private var currentProviderServerDescription: String? {
            guard let server = profile.providerServer(providerManager) else {
                return nil
            }
            if currentProfile.value.providerRandomizesServer ?? false {
                return server.localizedCountry(withCategory: true)
            } else {
                return server.localizedLongDescription(withCategory: true)
            }
        }

        private var currentProviderCountryImage: Image? {
            guard let code = profile.providerServer(providerManager)?.countryCode else {
                return nil
            }
            return themeAssetsCountryImage(code).asAssetImage
        }

        private var currentProviderPreset: String? {
            providerManager.localizedPreset(forProfile: profile)
        }

        private var lastInfrastructureUpdate: String? {
            providerManager.localizedInfrastructureUpdate(forProfile: profile)
        }

        private func refreshInfrastructure() {
            isRefreshingInfrastructure = true
            Task { @MainActor in
                try await providerManager.fetchRemoteProviderPublisher(forProfile: profile).async()
                isRefreshingInfrastructure = false
            }
        }
    }
}
