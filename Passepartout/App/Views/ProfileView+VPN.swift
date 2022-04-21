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
        @ObservedObject private var profileManager: ProfileManager

        @ObservedObject private var providerManager: ProviderManager

        @ObservedObject private var vpnManager: VPNManager

        @ObservedObject private var currentVPNState: VPNManager.ObservableState

        @ObservedObject private var productManager: ProductManager
        
        @ObservedObject private var currentProfile: ObservableProfile

        private let isLoaded: Bool

        private var isActiveProfile: Bool {
            profileManager.isCurrentProfileActive()
        }
        
        private var isEligibleForSiri: Bool {
            productManager.isEligible(forFeature: .siriShortcuts)
        }
        
        init(currentProfile: ObservableProfile, isLoaded: Bool) {
            profileManager = .shared
            providerManager = .shared
            vpnManager = .shared
            currentVPNState = .shared
            productManager = .shared
            self.currentProfile = currentProfile
            self.isLoaded = isLoaded
        }
        
        var body: some View {
            if isLoaded {
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
            Section(
                header: headerView,
                footer: Text(L10n.Profile.Sections.Vpn.footer)
                    .xxxThemeTruncation()
            ) {
                HStack {
                    Button(vpnToggleString, action: toggleVPNAndDonateIntents)
                        .disabled(vpnManager.isRateLimiting)
                    Spacer()
                    Toggle("", isOn: .constant(currentVPNState.isEnabled))
                        .disabled(true)
                }
                Text(L10n.Profile.Items.ConnectionStatus.caption)
                    .withTrailingText(currentVPNState.localizedStatusDescription(
                        withErrors: true,
                        withDataCount: true
                    ))
            }
        }

        private var vpnToggleString: String {
            let V = L10n.Profile.Items.Vpn.self
            return currentVPNState.isEnabled ? V.TurnOff.caption : V.TurnOn.caption
        }

        private var inactiveSubview: some View {
            Section(
                header: headerView
            ) {
                Button(L10n.Profile.Items.UseProfile.caption) {
                    withAnimation {
                        profileManager.activateCurrentProfile()
                    }
                    Task {
                        await vpnManager.disable()
                    }
                }
            }
        }
        
        private var loadingView: some View {
            Section(
                header: headerView
            ) {
                ProgressView()
            }
        }
        
        private func toggleVPNAndDonateIntents() {
            guard vpnManager.toggle() else {
                return
            }

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
    }

    struct UninstallVPNSection: View {
        @ObservedObject private var vpnManager: VPNManager
        
        @State private var isAskingUninstallVPN = false
        
        init() {
            vpnManager = .shared
        }
        
        var body: some View {
            Section {
                Button {
                    isAskingUninstallVPN = true
                } label: {
                    Label(L10n.Organizer.Items.Uninstall.caption, systemImage: themeDeleteImage)
                }.foregroundColor(themeErrorColor)
                .actionSheet(isPresented: $isAskingUninstallVPN) {
                    ActionSheet(
                        title: Text(L10n.Organizer.Alerts.UninstallVpn.message),
                        message: nil,
                        buttons: [
                            .destructive(Text(L10n.Organizer.Items.Uninstall.caption), action: {
                                Task {
                                    await vpnManager.uninstall()
                                }
                            }),
                            .cancel(Text(L10n.Global.Strings.cancel))
                        ]
                    )
                }
            }
        }
    }
}
