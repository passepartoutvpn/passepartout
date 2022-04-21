//
//  AddHostView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/18/22.
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
import TunnelKitOpenVPN
import TunnelKitWireGuard

struct AddHostView: View {
    @ObservedObject private var profileManager: ProfileManager
    
    private let url: URL
    
    private let deletingURLOnSuccess: Bool
    
    private let bindings: AddProfileView.Bindings
    
    @State private var viewModel = ViewModel()
    
    @State private var isEnteringCredentials = false
    
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
            List {
                if viewModel.processedProfile.isPlaceholder {
                    processingView
                } else {
                    completeView
                }
            }.animation(.default, value: viewModel)

            // hidden
            NavigationLink("", isActive: $isEnteringCredentials) {
                AddProfileView.AccountWrapperView(
                    profile: $viewModel.processedProfile,
                    bindings: bindings
                )
            }
        }.themeSecondaryView()
        .navigationTitle(L10n.AddProfile.Shared.title)
        .toolbar(content: toolbar)
        .alert(isPresented: $viewModel.isAskingOverwrite, content: alertOverwriteExistingProfile)
        .onAppear(perform: requestResourcePermissions)
        .onDisappear(perform: dropResourcePermissions)
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
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
    }
    
    @ViewBuilder
    private var processingView: some View {
        AddProfileView.ProfileNameSection(
            profileName: $viewModel.profileName,
            errorMessage: viewModel.errorMessage
        ) {
            processProfile(replacingExisting: false)
        }.onAppear {
            viewModel.presetName(withURL: url)
        }
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
    }
    
    private var encryptionSection: some View {
        Section(
            header: Text(L10n.Global.Strings.encryption)
        ) {
            SecureField(L10n.AddProfile.Host.Sections.Encryption.footer, text: $viewModel.encryptionPassphrase) {
                processProfile(replacingExisting: false)
            }
        }
    }

    private var completeView: some View {
        Section(
            footer: themeErrorMessage(viewModel.errorMessage)
        ) {
            Text(L10n.Global.Strings.name)
                .withTrailingText(viewModel.processedProfile.header.name)
            Text(Unlocalized.Network.url)
                .withTrailingText(url.lastPathComponent)
            viewModel.processedProfile.vpnProtocols.first.map {
                Text(L10n.Global.Strings.protocol)
                    .withTrailingText($0.description)
            }
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
        return Alert(
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
