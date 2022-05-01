//
//  ProfileView+VPN.swift
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
    struct VPNSection: View {
        @ObservedObject private var appManager: AppManager

        @ObservedObject private var profileManager: ProfileManager

        @ObservedObject private var providerManager: ProviderManager

        @ObservedObject private var vpnManager: VPNManager

        @ObservedObject private var currentVPNState: VPNManager.ObservableState

        @ObservedObject private var productManager: ProductManager
        
        @ObservedObject private var currentProfile: ObservableProfile

        private let isLoading: Bool

        private var isActiveProfile: Bool {
            profileManager.isCurrentProfileActive()
        }
        
        private var isEligibleForSiri: Bool {
            productManager.isEligible(forFeature: .siriShortcuts)
        }
        
        init(currentProfile: ObservableProfile, isLoading: Bool) {
            appManager = .shared
            profileManager = .shared
            providerManager = .shared
            vpnManager = .shared
            currentVPNState = .shared
            productManager = .shared
            self.currentProfile = currentProfile
            self.isLoading = isLoading
        }
        
        var body: some View {
            if !isLoading {
                if isActiveProfile {
                    activeView
                } else {
                    inactiveSubview
                }
            } else {
                loadingView
            }
        }
        
        private var headerView: some View {
            Text(Unlocalized.VPN.vpn)
        }
        
        private var activeView: some View {
            Section {
                VPNToggle(rateLimit: Constants.RateLimit.vpnToggle) {

                    // eligibility: donate intents if eligible for Siri
                    if isEligibleForSiri {
                        pp_log.debug("Donating connection intents...")

                        IntentDispatcher.donateEnableVPN()
                        IntentDispatcher.donateDisableVPN()
                        IntentDispatcher.donateConnection(
                            with: currentProfile.value,
                            providerManager: providerManager
                        )
                    }
                }

                Text(L10n.Profile.Items.ConnectionStatus.caption)
                    .withTrailingText(currentVPNState.localizedStatusDescription(
                        withErrors: true,
                        dataCountIfAvailable: true
                    ))
            } header: {
                headerView
            } footer: {
                Text(L10n.Profile.Sections.Vpn.footer)
                    .xxxThemeTruncation()
            }
        }

        private var inactiveSubview: some View {
            Section {
                Button(L10n.Profile.Items.UseProfile.caption) {
                    Task {

                        // do this first to not override subsequent animation
                        // active profile may flicker due to unnecessary VPN updates
                        await vpnManager.disable()

                        withAnimation {
                            profileManager.activateCurrentProfile()

                            // IMPORTANT: save immediately to keep in sync with VPN status
                            appManager.activeProfileId = profileManager.activeHeader?.id
                        }
                    }
                }
            } header: {
                headerView
            }
        }
        
        private var loadingView: some View {
            Section {
                ProgressView()
            } header: {
                headerView
            }
        }
    }
}
