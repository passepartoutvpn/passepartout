//
//  OnDemandView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/23/22.
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

struct OnDemandView: View {
    @ObservedObject private var productManager: ProductManager

    @ObservedObject private var currentProfile: ObservableProfile

    @State private var onDemand = Profile.OnDemand()

    init(currentProfile: ObservableProfile) {
        productManager = .shared
        self.currentProfile = currentProfile
    }

    var body: some View {
        debugChanges()
        return List {
            enabledView
            if onDemand.isEnabled && onDemand.policy != .any {
                mainView
            }
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

// MARK: -

private extension OnDemandView {
    var enabledView: some View {
        Section {
            Toggle(L10n.Global.Strings.enabled, isOn: $onDemand.isEnabled.themeAnimation())
            if onDemand.isEnabled {
                themeTextPicker(
                    L10n.Global.Strings.policy,
                    selection: $onDemand.policy,
                    values: [.any, .including, .excluding],
                    description: \.localizedDescription
                )
            }
        } footer: {
            Text(policyFooterDescription)
        }
    }

    var policyFooterDescription: String {
        guard onDemand.isEnabled else {
            return "" // better animation than removing footer completely
        }
        let suffix: String
        switch onDemand.policy {
        case .any:
            suffix = L10n.OnDemand.Sections.Policy.Footer.any

        case .including, .excluding:
            if onDemand.policy == .including {
                suffix = L10n.OnDemand.Sections.Policy.Footer.including
            } else {
                suffix = L10n.OnDemand.Sections.Policy.Footer.excluding
            }
        }
        return L10n.OnDemand.Sections.Policy.footer(suffix)
    }

    @ViewBuilder
    var mainView: some View {
        if Utils.hasCellularData() {
            Section {
                Toggle(L10n.OnDemand.Items.Mobile.caption, isOn: $onDemand.withMobileNetwork)
            } header: {
                Text(L10n.Global.Strings.networks)
            }
        } else if Utils.hasEthernet() {
            Section {
                Toggle(L10n.OnDemand.Items.Ethernet.caption, isOn: $onDemand.withEthernetNetwork)
            } header: {
                Text(L10n.Global.Strings.networks)
            }
        }
        Section {
            SSIDList(withSSIDs: $onDemand.withSSIDs)
        } header: {
            if !Utils.hasCellularData() && !Utils.hasEthernet() {
                Text(L10n.Global.Strings.networks)
            }
        }
    }

    var isEligibleForSiri: Bool {
        productManager.isEligible(forFeature: .siriShortcuts)
    }
}

// MARK: -

private extension OnDemandView {

    // eligibility: donate intents if eligible for Siri
    func donateMobileIntent(_ isEnabled: Bool) {
        guard isEligibleForSiri else {
            return
        }
        #if !os(tvOS)
        IntentDispatcher.donateTrustCellularNetwork()
        IntentDispatcher.donateUntrustCellularNetwork()
        #endif
    }

    // eligibility: donate intents if eligible for Siri
    func donateNetworkIntents(_: [String: Bool]) {
        guard isEligibleForSiri else {
            return
        }
        #if !os(tvOS)
        IntentDispatcher.donateTrustCurrentNetwork()
        IntentDispatcher.donateUntrustCurrentNetwork()
        #endif
    }
}
