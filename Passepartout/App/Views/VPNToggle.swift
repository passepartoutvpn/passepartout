//
//  VPNToggle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/26/22.
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
import PassepartoutLibrary

struct VPNToggle: View {
    @ObservedObject private var profileManager: Impl.ProfileManager

    @ObservedObject private var vpnManager: Impl.VPNManager

    @ObservedObject private var currentVPNState: ObservableVPNState

    @ObservedObject private var productManager: ProductManager

    private let profileId: UUID

    private let rateLimit: Int
    
    private var isEnabled: Binding<Bool> {
        .init {
            isActiveProfile && currentVPNState.isEnabled
        } set: { newValue in
            guard newValue else {
                disableVPN()
                return
            }
            enableVPN()
        }
    }
    
    private var isActiveProfile: Bool {
        profileManager.isActiveProfile(profileId)
    }

    private var isEligibleForSiri: Bool {
        productManager.isEligible(forFeature: .siriShortcuts)
    }
    
    @State private var canToggle = true
    
    init(profileId: UUID, rateLimit: Int) {
        profileManager = .shared
        vpnManager = .shared
        currentVPNState = .shared
        productManager = .shared
        self.profileId = profileId
        self.rateLimit = rateLimit
    }

    var body: some View {
        Toggle(L10n.Global.Strings.enabled, isOn: isEnabled)
            .disabled(!canToggle)
            .themeAnimation(on: currentVPNState.isEnabled)
    }
    
    private func enableVPN() {
        Task {
            canToggle = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(rateLimit)) {
                canToggle = true
            }
            do {
                let profile = try await vpnManager.connect(with: profileId)
                donateIntents(withProfile: profile)
            } catch {
                pp_log.warning("Unable to connect to profile \(profileId): \(error)")
                canToggle = true
            }
        }
    }
    
    private func disableVPN() {
        Task {
            canToggle = false
            await vpnManager.disable()
            canToggle = true
        }
    }
    
    private func donateIntents(withProfile profile: Profile) {

        // eligibility: donate intents if eligible for Siri
        guard isEligibleForSiri else {
            return
        }

        pp_log.debug("Donating connection intents...")

        IntentDispatcher.donateEnableVPN()
        IntentDispatcher.donateDisableVPN()
        IntentDispatcher.donateConnection(
            with: profile,
            providerManager: Impl.ProviderManager.shared
        )
    }
}
