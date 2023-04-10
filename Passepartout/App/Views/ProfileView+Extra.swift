//
//  ProfileView+Extra.swift
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
    struct ExtraSection: View {
        @ObservedObject private var currentProfile: ObservableProfile

        init(currentProfile: ObservableProfile) {
            self.currentProfile = currentProfile
        }

        var body: some View {
            Section {
                Toggle(
                    L10n.Profile.Items.VpnSurvivesSleep.caption,
                    isOn: $currentProfile.value.networkSettings.keepsAliveOnSleep
                )
            } footer: {
                Text(L10n.Profile.Sections.VpnSurvivesSleep.footer)
            }
        }
    }
}
