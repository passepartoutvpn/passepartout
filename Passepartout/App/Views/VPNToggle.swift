//
//  VPNToggle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/26/22.
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

struct VPNToggle: View {
    @ObservedObject private var profileManager: ProfileManager

    @ObservedObject private var vpnManager: VPNManager

    @ObservedObject private var currentVPNState: ObservableVPNState

    @ObservedObject private var productManager: ProductManager

    private let profile: Profile

    @Binding private var interactiveProfile: Profile?

    private let rateLimit: Int

    private var isEnabled: Binding<Bool> {
        .init {
            isActiveProfile && currentVPNState.isEnabled && !shouldPromptForAccount
        } set: { newValue in
            guard !shouldPromptForAccount else {
                interactiveProfile = profile
                return
            }
            guard newValue else {
                disableVPN()
                return
            }
            enableVPN()
        }
    }

    private var isActiveProfile: Bool {
        profileManager.isActiveProfile(profile.id)
    }

    private var shouldPromptForAccount: Bool {
        profile.account.authenticationMethod == .interactive && (currentVPNState.vpnStatus == .disconnecting || currentVPNState.vpnStatus == .disconnected)
    }

    private var isEligibleForSiri: Bool {
        productManager.isEligible(forFeature: .siriShortcuts)
    }

    @State private var canToggle = true

    init(profile: Profile, interactiveProfile: Binding<Profile?>, rateLimit: Int) {
        profileManager = .shared
        vpnManager = .shared
        currentVPNState = .shared
        productManager = .shared
        self.profile = profile
        _interactiveProfile = interactiveProfile
        self.rateLimit = rateLimit
    }

    var body: some View {
        Toggle(L10n.Global.Strings.enabled, isOn: isEnabled)
            .disabled(!canToggle)
            .themeAnimation(on: currentVPNState.isEnabled)
    }

    private func enableVPN() {
        Task { @MainActor in
            canToggle = false
            await Task.maybeWait(forMilliseconds: rateLimit)
            canToggle = true
            do {
                let profile = try await vpnManager.connect(with: profile.id)
                donateIntents(withProfile: profile)
            } catch {
                pp_log.warning("Unable to connect to profile \(profile.id): \(error)")
                canToggle = true
            }
        }
    }

    private func disableVPN() {
        Task { @MainActor in
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
            providerManager: ProviderManager.shared
        )
    }
}
