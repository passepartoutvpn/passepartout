//
//  ProfileView+Diagnostics.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/27/22.
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

extension ProfileView {
    struct DiagnosticsSection: View {
        @ObservedObject private var profileManager: Impl.ProfileManager

        @ObservedObject private var currentProfile: ObservableProfile

        private var isActiveProfile: Bool {
            profileManager.isCurrentProfileActive()
        }
        
        private var vpnProtocol: VPNProtocolType {
            currentProfile.value.currentVPNProtocol
        }
        
        private var providerName: ProviderName? {
            currentProfile.value.header.providerName
        }
        
        private let faqURL = Constants.URLs.faq
        
        init(currentProfile: ObservableProfile) {
            profileManager = .shared
            self.currentProfile = currentProfile
        }
        
        var body: some View {
            Section {
                if isActiveProfile {
                    NavigationLink {
                        DiagnosticsView(
                            vpnProtocol: vpnProtocol,
                            providerName: providerName
                        )
                    } label: {
                        Label(L10n.Diagnostics.title, systemImage: themeDiagnosticsImage)
                    }
                }
                Button {
                    URL.openURL(faqURL)
                } label: {
                    Label(Unlocalized.About.faq, systemImage: themeFAQImage)
                }
            } header: {
                Text(L10n.Profile.Sections.Feedback.header)
            }
        }
    }
}
