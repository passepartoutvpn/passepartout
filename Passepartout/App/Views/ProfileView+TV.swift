//
//  ProfileView+TV.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/22/23.
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

extension ProfileView {
    struct TVSection: View {
        @ObservedObject private var profileManager: ProfileManager

        @ObservedObject private var productManager: ProductManager

        @ObservedObject private var currentProfile: ObservableProfile

        @Binding private var isProfileShared: Bool

        @Binding private var modalType: ModalType?

        init(currentProfile: ObservableProfile, modalType: Binding<ModalType?>) {
            let profileManager: ProfileManager = .shared

            self.profileManager = profileManager
            productManager = .shared
            self.currentProfile = currentProfile
            _isProfileShared = Binding {
                profileManager.isSharing(profile: currentProfile.value)
            } set: {
                profileManager.setSharing($0, profile: currentProfile.value)
            }
            _modalType = modalType
        }

        var body: some View {
            Section {
                Toggle(isOn: $isProfileShared) {
                    Label(shareText, systemImage: themeAppleTVImage)
                }

                // eligibility: present paywall for full support for Apple TV
                if !isEligibleForAppleTV {
                    Button(L10n.Paywall.title) {
                        modalType = .paywallAppleTV
                    }
                }
            } footer: {
                Text(footerText)
            }
        }
    }
}

private extension ProfileView.TVSection {
    var isEligibleForAppleTV: Bool {
        productManager.isEligible(forFeature: .appleTV)
    }

    var shareText: String {
        var sentences: [String] = [Unlocalized.Other.appleTV]
        if !isEligibleForAppleTV {
            sentences.append(L10n.Profile.Items.TvSharing.Caption.limited(Constants.InApp.tvLimitedMinutes))
        }
        return sentences.joined(separator: " — ")
    }

    var footerText: String {
        var sentences: [String] = [L10n.Profile.Sections.Tv.Footer.encryption]
        if !isEligibleForAppleTV {
            sentences.append(L10n.Profile.Sections.Tv.Footer.Restricted.p1(Constants.InApp.tvLimitedMinutes))
            sentences.append(L10n.Profile.Sections.Tv.Footer.Restricted.p2)
        }
        return sentences.joined(separator: " ")
    }
}
