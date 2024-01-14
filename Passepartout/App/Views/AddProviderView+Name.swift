//
//  AddProviderView+Name.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/19/22.
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

extension AddProviderView {
    struct NameView: View {
        @ObservedObject private var profileManager: ProfileManager

        @Binding private var profile: Profile

        private let providerMetadata: ProviderMetadata

        private let bindings: AddProfileView.Bindings

        @State private var viewModel = ViewModel()

        @State private var isEnteringCredentials = false

        @FocusState private var focusedField: AddProfileView.Field?

        init(
            profile: Binding<Profile>,
            providerMetadata: ProviderMetadata,
            bindings: AddProfileView.Bindings
        ) {
            profileManager = .shared
            _profile = profile
            self.providerMetadata = providerMetadata
            self.bindings = bindings
        }

        var body: some View {
            ZStack {
                hiddenAccountLink
                List {
                    AddProfileView.ProfileNameSection(
                        profileName: $viewModel.profileName,
                        focusedField: $focusedField,
                        errorMessage: viewModel.errorMessage
                    ) {
                        saveProfile(replacingExisting: false)
                    }.onAppear {
                        viewModel.presetName(withMetadata: providerMetadata)
                    }
                    let headers = profileManager.headers.sorted()
                    if !headers.isEmpty {
                        AddProfileView.ExistingProfilesSection(
                            headers: headers,
                            profileName: $viewModel.profileName
                        )
                    }
                }
            }.toolbar {
                Button {
                    saveProfile(replacingExisting: false)
                } label: {
                    themeSaveButtonLabel()
                }
            }.alert(
                L10n.AddProfile.Shared.title,
                isPresented: $viewModel.isAskingOverwrite,
                actions: alertOverwriteActions,
                message: alertOverwriteMessage
            ).navigationTitle(providerMetadata.fullName)
        }
    }
}

// MARK: -

private extension AddProviderView.NameView {
    var hiddenAccountLink: some View {
        NavigationLink("", isActive: $isEnteringCredentials) {
            AddProfileView.AccountWrapperView(
                profile: $profile,
                bindings: bindings
            )
        }
    }

    @ViewBuilder
    func alertOverwriteActions() -> some View {
        Button(role: .destructive) {
            saveProfile(replacingExisting: true)
        } label: {
            Text(L10n.Global.Strings.ok)
        }
        Button(role: .cancel) {
        } label: {
            Text(L10n.Global.Strings.cancel)
        }
    }

    func alertOverwriteMessage() -> some View {
        Text(L10n.AddProfile.Shared.Alerts.Overwrite.message)
    }
}

// MARK: -

private extension AddProviderView.NameView {
    func saveProfile(replacingExisting: Bool) {
        let addedProfile = viewModel.addProfile(
            profile,
            to: profileManager,
            replacingExisting: replacingExisting
        )
        guard let addedProfile = addedProfile else {
            return
        }
        profile = addedProfile

        if profile.requiresCredentials {
            isEnteringCredentials = true
        } else {
            bindings.isPresented = false
            profileManager.didCreateProfile.send(profile)
        }
    }
}
