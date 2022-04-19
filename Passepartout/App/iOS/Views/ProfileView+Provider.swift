//
//  ProfileView+Provider.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/18/22.
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
    struct ProviderSection: View {
        @ObservedObject private var providerManager: ProviderManager
        
        @ObservedObject private var currentProfile: ObservableProfile
        
        @State private var isProviderLocationPresented = false

        @State private var isRefreshingInfrastructure = false
        
        init(currentProfile: ObservableProfile) {
            providerManager = .shared
            self.currentProfile = currentProfile
        }

        var body: some View {
            debugChanges()
            return Group {
                if canDisplay {
                    mainView
                } else {
                    EmptyView()
                }
            }
        }
        
        private var canDisplay: Bool {
            guard !currentProfile.value.isPlaceholder else {
                return false
            }
            guard let providerName = currentProfile.value.header.providerName else {
                return false
            }
            return providerManager.isAvailable(providerName, vpnProtocol: currentProfile.value.currentVPNProtocol)
        }
        
        private var mainView: some View {
            Section(
                header: Text(currentProvider.fullName),
                footer: lastInfrastructureUpdate.map {
                    Text(L10n.Profile.Sections.ProviderInfrastructure.footer($0))
                 }
            ) {
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
                NavigationLink {
                    ProviderPresetView(currentProfile: currentProfile)
                } label: {
                    Label(L10n.Provider.Preset.title, systemImage: themeProviderPresetImage)
                        .withTrailingText(currentProviderPreset)
                }
                Button(action: refreshInfrastructure) {
                    Text(L10n.Profile.Items.Provider.Refresh.caption)
                }.withTrailingProgress(when: isRefreshingInfrastructure)
            }
        }

        private var currentProvider: ProviderMetadata {
            guard let name = currentProfile.value.header.providerName else {
                fatalError("Provider name accessed but profile is not a provider (isPlaceholder? \(currentProfile.value.isPlaceholder))")
            }
            guard let metadata = providerManager.provider(withName: name) else {
                fatalError("Provider metadata not found")
            }
            return metadata
        }

//        private var currentProviderLocation: String? {
//            return providerManager.localizedLocation(forProfile: profile)
//        }
        private var currentProviderCountryImage: Image? {
            guard let code = currentProfile.value.providerServer(providerManager)?.countryCode else {
                return nil
            }
            return themeAssetsCountryImage(code).asAssetImage
        }
        
        private var currentProviderPreset: String? {
            return providerManager.localizedPreset(forProfile: currentProfile.value)
        }
        
        private var lastInfrastructureUpdate: String? {
            return providerManager.localizedInfrastructureUpdate(forProfile: currentProfile.value)
        }

        private func refreshInfrastructure() {
            isRefreshingInfrastructure = true
            Task {
                try await providerManager.fetchRemoteProviderPublisher(forProfile: currentProfile.value).async()
                isRefreshingInfrastructure = false
            }
        }
    }
}
