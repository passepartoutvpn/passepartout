//
//  ProfileView+VPN.swift
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
    struct VPNSection: View {
        @ObservedObject private var profileManager: ProfileManager

        private let profile: Profile

        @Binding private var modalType: ModalType?

        private var interactiveProfile: Binding<Profile?> {
            .init {
                modalType == .interactiveAccount ? profile : nil
            } set: {
                modalType = $0 != nil ? .interactiveAccount : nil
            }
        }

        private var isActiveProfile: Bool {
            profileManager.isActiveProfile(profile.id)
        }

        init(profile: Profile, modalType: Binding<ModalType?>) {
            profileManager = .shared
            self.profile = profile
            _modalType = modalType
        }

        var body: some View {
            Section {
                toggleView
                statusView
            } header: {
                Text(Unlocalized.VPN.vpn)
            } footer: {
                Text(L10n.Profile.Sections.Vpn.footer)
                    .xxxThemeTruncation()
            }
        }

        private var toggleView: some View {
            VPNToggle(
                profile: profile,
                interactiveProfile: interactiveProfile,
                rateLimit: Constants.RateLimit.vpnToggle
            )
        }

        private var statusView: some View {
            HStack {
                Text(L10n.Profile.Items.ConnectionStatus.caption)
                Spacer()
                VPNStatusText(isActiveProfile: isActiveProfile)
                    .themeSecondaryTextStyle()
            }
        }
    }
}
