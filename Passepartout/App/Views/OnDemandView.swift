//
//  OnDemandView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/23/22.
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

struct OnDemandView: View {
    @ObservedObject private var productManager: ProductManager

    @ObservedObject private var currentProfile: ObservableProfile

    private var isEligibleForSiri: Bool {
        productManager.isEligible(forFeature: .siriShortcuts)
    }

    @State private var onDemand = Profile.OnDemand()

    init(currentProfile: ObservableProfile) {
        productManager = .shared
        self.currentProfile = currentProfile
    }

    var body: some View {
        debugChanges()
        return List {
            // TODO: on-demand, restore when "trusted networks" -> "on-demand"
//            enabledView
//            if onDemand.isEnabled {
                mainView
//            }
        }.navigationTitle(L10n.OnDemand.title)
        .toolbar {
            CopySavingButton(
                original: $currentProfile.value.onDemand,
                copy: $onDemand,
                mapping: \.stripped,
                label: themeSaveButtonLabel
            )
        }

        // Siri
        .onChange(of: onDemand.withMobileNetwork, perform: donateMobileIntent)
        .onChange(of: onDemand.withSSIDs, perform: donateNetworkIntents)
    }
}

extension OnDemandView {
    private var enabledView: some View {
        Section {
            Toggle(L10n.Global.Strings.enabled, isOn: $onDemand.isEnabled.themeAnimation())
        }
    }

    @ViewBuilder
    private var mainView: some View {
        if Utils.hasCellularData() {
            Section {
                Toggle(L10n.OnDemand.Items.Mobile.caption, isOn: $onDemand.withMobileNetwork)
            } header: {
                // TODO: on-demand, restore when "trusted networks" -> "on-demand"
//                Text(L10n.Profile.Sections.Trusted.header)
            }
            Section {
                SSIDList(withSSIDs: $onDemand.withSSIDs)
            }
        } else if Utils.hasEthernet() {
            Section {
                Toggle(L10n.OnDemand.Items.Ethernet.caption, isOn: $onDemand.withEthernetNetwork)
            } header: {
                // TODO: on-demand, restore when "trusted networks" -> "on-demand"
//                Text(L10n.Profile.Sections.Trusted.header)
            }
            Section {
                SSIDList(withSSIDs: $onDemand.withSSIDs)
            }
        } else {
            Section {
                SSIDList(withSSIDs: $onDemand.withSSIDs)
            } header: {
                // TODO: on-demand, restore when "trusted networks" -> "on-demand"
//                Text(L10n.Profile.Sections.Trusted.header)
            }
        }
        Section {
            Toggle(L10n.OnDemand.Items.Policy.caption, isOn: $onDemand.disconnectsIfNotMatching)
        } footer: {
            Text(L10n.OnDemand.Sections.Policy.footer)
        }
    }

    // eligibility: donate intents if eligible for Siri
    private func donateMobileIntent(_ isEnabled: Bool) {
        guard isEligibleForSiri else {
            return
        }
        IntentDispatcher.donateTrustCellularNetwork()
        IntentDispatcher.donateUntrustCellularNetwork()
    }

    // eligibility: donate intents if eligible for Siri
    private func donateNetworkIntents(_: [String: Bool]) {
        guard isEligibleForSiri else {
            return
        }
        IntentDispatcher.donateTrustCurrentNetwork()
        IntentDispatcher.donateUntrustCurrentNetwork()
    }
}
