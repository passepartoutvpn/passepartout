//
//  OrganizerView+ProfileRow.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/28/22.
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

extension OrganizerView {
    struct ProfileRow: View {
        private let profile: Profile

        private let isActiveProfile: Bool

        @Binding private var modalType: ModalType?

        private var interactiveProfile: Binding<Profile?> {
            .init {
                if case .interactiveAccount(let profile) = modalType {
                    return profile
                }
                return nil
            } set: {
                if let profile = $0 {
                    modalType = .interactiveAccount(profile: profile)
                } else {
                    modalType = nil
                }
            }
        }

        init(profile: Profile, isActiveProfile: Bool, modalType: Binding<ModalType?>) {
            self.profile = profile
            self.isActiveProfile = isActiveProfile
            _modalType = modalType
        }

        var body: some View {
            debugChanges()
            return HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(profile.header.name)
                        .font(.headline)
                        .themeLongTextStyle()

                    VPNStatusText(isActiveProfile: isActiveProfile)
                        .font(.subheadline)
                        .themeSecondaryTextStyle()
                }
                Spacer()
                VPNToggle(
                    profile: profile,
                    interactiveProfile: interactiveProfile,
                    rateLimit: Constants.RateLimit.vpnToggle
                ).labelsHidden()
            }.padding([.top, .bottom], 10)
        }
    }
}
