//
//  ProfileView+MenuBar.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/6/22.
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
    struct MenuBar: View {
        @ObservedObject private var productManager: ProductManager
        
        @ObservedObject private var currentProfile: ObservableProfile
        
        @Binding private var modalType: ModalType?
        
        private var isEligibleForSiri: Bool {
            productManager.isEligible(forFeature: .siriShortcuts)
        }
        
        init(currentProfile: ObservableProfile, modalType: Binding<ModalType?>) {
            productManager = .shared
            self.currentProfile = currentProfile
            _modalType = modalType
        }
        
        var body: some View {
            Button {
                presentShortcutsOrPaywall()
            } label: {
                themeShortcutsImage.asSystemImage
            }
            Button {
                modalType = .rename
            } label: {
                themeRenameProfileImage.asSystemImage
            }
        }

        private func presentShortcutsOrPaywall() {

            // eligibility: enter Siri shortcuts or present paywall
            if isEligibleForSiri {
                modalType = .shortcuts
            } else {
                modalType = .paywallShortcuts
            }
        }
    }
}
