//
//  AddProfileView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/19/22.
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

enum AddProfileView {
    struct Bindings {
        @Binding var isPresented: Bool
    }

    struct ProfileNameSection: View {
        @Binding var profileName: String

        let errorMessage: String?

        let onCommit: () -> Void

        var body: some View {
            Section {
                TextField(L10n.Global.Placeholders.profileName, text: $profileName, onCommit: onCommit)
                    .themeValidProfileName()
            } header: {
                Text(L10n.Global.Strings.name)
            } footer: {
                themeErrorMessage(errorMessage)
            }
        }
    }

    struct ExistingProfilesSection: View {
        let headers: [Profile.Header]

        @Binding var profileName: String

        var body: some View {
            Section {
                ForEach(headers, content: existingProfileButton)
            } header: {
                Text(L10n.AddProfile.Shared.Views.Existing.header)
            }
        }

        private func existingProfileButton(_ header: Profile.Header) -> some View {
            Button(header.name) {
                profileName = header.name
            }.themeLongTextStyle()
        }
    }

    struct AccountWrapperView: View {
        @ObservedObject private var profileManager: ProfileManager

        @Binding private var profile: Profile

        private let bindings: AddProfileView.Bindings

        @State private var account = Profile.Account()

        init(
            profile: Binding<Profile>,
            bindings: AddProfileView.Bindings
        ) {
            profileManager = .shared
            _profile = profile
            self.bindings = bindings
        }

        var body: some View {
            AccountView(
                providerName: profile.header.providerName,
                vpnProtocol: profile.currentVPNProtocol,
                account: $account,
                saveAnyway: true,
                onSave: {
                    bindings.isPresented = false
                }
            ).navigationBarBackButtonHidden(true)
            .onDisappear(perform: saveAccount)
        }

        private func saveAccount() {
            profile.account = account
            profileManager.saveProfile(profile, isActive: nil)
            profileManager.didCreateProfile.send(profile)
        }
    }
}
