//
//  ProfileView+Configuration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/27/22.
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
    struct ConfigurationSection: View {
        @ObservedObject private var productManager: ProductManager

        @ObservedObject private var currentProfile: ObservableProfile

        @Binding private var modalType: ModalType?

        private var isEligibleForNetworkSettings: Bool {
            productManager.isEligible(forFeature: .networkSettings)
        }

        private var isEligibleForTrustedNetworks: Bool {
            productManager.isEligible(forFeature: .trustedNetworks)
        }

        init(currentProfile: ObservableProfile, modalType: Binding<ModalType?>) {
            productManager = .shared
            self.currentProfile = currentProfile
            _modalType = modalType
        }

        var body: some View {
            Section {
                if currentProfile.value.vpnProtocols.count > 1 {
                    themeTextPicker(
                        L10n.Global.Strings.protocol,
                        selection: $currentProfile.value.currentVPNProtocol,
                        values: currentProfile.value.vpnProtocols,
                        description: \.description
                    )
                } else {
                    Label(L10n.Global.Strings.protocol, systemImage: themeVPNProtocolImage)
                        .withTrailingText(currentProfile.value.currentVPNProtocol.description)
                }
                NavigationLink {
                    EndpointView(currentProfile: currentProfile)
                } label: {
                    Label(L10n.Global.Strings.endpoint, systemImage: themeEndpointImage)
                }
                if currentProfile.value.requiresCredentials {
                    NavigationLink {
                        AccountView(
                            providerName: currentProfile.value.header.providerName,
                            vpnProtocol: currentProfile.value.currentVPNProtocol,
                            account: $currentProfile.value.account
                        )
                    } label: {
                        Label(L10n.Account.title, systemImage: themeAccountImage)
                    }
                }

                // eligibility: enter network settings or present paywall
                if isEligibleForNetworkSettings {
                    NavigationLink {
                        NetworkSettingsView(currentProfile: currentProfile)
                    } label: {
                        networkSettingsRow
                    }
                } else {
                    Button {
                        modalType = .paywallNetworkSettings
                    } label: {
                        networkSettingsRow
                    }
                }

                // eligibility: enter trusted networks or present paywall
                if isEligibleForTrustedNetworks {
                    NavigationLink {
                        OnDemandView(currentProfile: currentProfile)
                    } label: {
                        onDemandRow
                    }
                } else {
                    Button {
                        modalType = .paywallTrustedNetworks
                    } label: {
                        onDemandRow
                    }
                }
            } header: {
                Text(L10n.Global.Strings.configuration)
            }
        }

        private var networkSettingsRow: some View {
            Label(L10n.NetworkSettings.title, systemImage: themeNetworkSettingsImage)
        }

        private var onDemandRow: some View {
            Label(L10n.OnDemand.title, systemImage: themeOnDemandImage)
        }
    }
}
