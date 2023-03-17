//
//  AddHostView+Name.swift
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
import TunnelKitOpenVPN
import TunnelKitWireGuard

extension AddHostView {
    struct NameView: View {
        @ObservedObject private var profileManager: ProfileManager

        private let url: URL

        private let deletingURLOnSuccess: Bool

        private let bindings: AddProfileView.Bindings

        @State private var viewModel = ViewModel()

        @State private var isEnteringCredentials = false

        private var isComplete: Bool {
            !viewModel.processedProfile.isPlaceholder
        }

        init(
            url: URL,
            deletingURLOnSuccess: Bool,
            bindings: AddProfileView.Bindings
        ) {
            profileManager = .shared
            self.url = url
            self.deletingURLOnSuccess = deletingURLOnSuccess
            self.bindings = bindings
        }

        var body: some View {
            ZStack {
                hiddenAccountLink
                List {
                    mainView
                }.themeAnimation(on: viewModel)
            }.toolbar {
                themeCloseItem(isPresented: bindings.$isPresented)
                ToolbarItem(placement: .primaryAction) {
                    Button(nextString) {
                        if !viewModel.processedProfile.isPlaceholder {
                            saveProfile()
                        } else {
                            processProfile(replacingExisting: false)
                        }
                    }
                }
            }.alert(isPresented: $viewModel.isAskingOverwrite, content: alertOverwriteExistingProfile)
            .onAppear(perform: requestResourcePermissions)
            .onDisappear(perform: dropResourcePermissions)
            .navigationTitle(L10n.AddProfile.Shared.title)
            .themeSecondaryView()
        }

        @ViewBuilder
        private var mainView: some View {
            AddProfileView.ProfileNameSection(
                profileName: $viewModel.profileName,
                errorMessage: viewModel.errorMessage
            ) {
                processProfile(replacingExisting: false)
            }.onAppear {
                viewModel.presetName(withURL: url)
            }.disabled(isComplete)

            if !isComplete {
                if viewModel.requiresPassphrase {
                    encryptionSection
                }
                let headers = profileManager.headers.sorted()
                if !headers.isEmpty {
                    AddProfileView.ExistingProfilesSection(
                        headers: headers,
                        profileName: $viewModel.profileName
                    )
                }
            } else {
                completeSection
            }
        }

        private var encryptionSection: some View {
            Section {
                SecureField(L10n.AddProfile.Host.Sections.Encryption.footer, text: $viewModel.encryptionPassphrase) {
                    processProfile(replacingExisting: false)
                }
            } header: {
                Text(L10n.Global.Strings.encryption)
            }
        }

        private var completeSection: some View {
            Section {
                Text(Unlocalized.Network.url)
                    .withTrailingText(url.lastPathComponent)
                viewModel.processedProfile.vpnProtocols.first.map {
                    Text(L10n.Global.Strings.protocol)
                        .withTrailingText($0.description)
                }
            } header: {
                Text(L10n.AddProfile.Shared.title)
            } footer: {
                themeErrorMessage(viewModel.errorMessage)
            }
        }

        private var hiddenAccountLink: some View {
            NavigationLink("", isActive: $isEnteringCredentials) {
                AddProfileView.AccountWrapperView(
                    profile: $viewModel.processedProfile,
                    bindings: bindings
                )
            }
        }

        private var nextString: String {
            if !viewModel.processedProfile.isPlaceholder {
                return viewModel.processedProfile.requiresCredentials ? L10n.Global.Strings.next : L10n.Global.Strings.save
            } else {
                return L10n.Global.Strings.next
            }
        }

        private func requestResourcePermissions() {
            _ = url.startAccessingSecurityScopedResource()
        }

        private func dropResourcePermissions() {
            url.stopAccessingSecurityScopedResource()
        }

        private func alertOverwriteExistingProfile() -> Alert {
            Alert(
                title: Text(L10n.AddProfile.Shared.title),
                message: Text(L10n.AddProfile.Shared.Alerts.Overwrite.message),
                primaryButton: .destructive(Text(L10n.Global.Strings.ok)) {
                    processProfile(replacingExisting: true)
                },
                secondaryButton: .cancel(Text(L10n.Global.Strings.cancel))
            )
        }

        private func processProfile(replacingExisting: Bool) {
            viewModel.processURL(
                url,
                with: profileManager,
                replacingExisting: replacingExisting,
                deletingURLOnSuccess: deletingURLOnSuccess
            )
        }

        private func saveProfile() {
            let result = viewModel.addProcessedProfile(to: profileManager)
            guard result else {
                return
            }

            let profile = viewModel.processedProfile
            if profile.requiresCredentials {
                isEnteringCredentials = true
            } else {
                bindings.isPresented = false
                profileManager.didCreateProfile.send(profile)
            }
        }
    }
}
