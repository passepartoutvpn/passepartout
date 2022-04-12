//
//  ProfileView.swift
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
    struct RenameView: View {
        @Environment(\.presentationMode) private var presentationMode
        
        @ObservedObject private var profileManager: ProfileManager
        
        @ObservedObject private var currentProfile: ObservableProfile
        
        @State private var newName = ""
        
        @State private var isOverwritingExistingProfile = false
        
        init(currentProfile: ObservableProfile) {
            profileManager = .shared
            self.currentProfile = currentProfile
        }
        
        var body: some View {
            List {
                Section(
                    header: Text(L10n.Profile.Alerts.Rename.title)
                ) {
                    TextField(L10n.Global.Placeholders.profileName, text: $newName, onCommit: commitRenaming)
                        .disableAutocorrection(true)
                        .onAppear(perform: loadCurrentName)
                }
            }.themeSecondaryView()
            .navigationTitle(currentProfile.value.header.name)
            .toolbar {
                Button(action: commitRenaming) {
                    themeDoneButtonLabel()
                }
            }.alert(isPresented: $isOverwritingExistingProfile, content: alertOverwriteExistingProfile)
        }
        
        private func alertOverwriteExistingProfile() -> Alert {
            return Alert(
                title: Text(L10n.Profile.Alerts.Rename.title),
                message: Text(L10n.AddProfile.Shared.Alerts.Overwrite.message),
                primaryButton: .destructive(Text(L10n.Global.Strings.ok)) {
                    commitRenaming(force: true)
                },
                secondaryButton: .cancel(Text(L10n.Global.Strings.cancel))
            )
        }
        
        private func loadCurrentName() {
            newName = currentProfile.value.header.name
        }

        private func commitRenaming() {
            commitRenaming(force: false)
        }

        private func commitRenaming(force: Bool) {
            let name = newName.stripped

            guard !name.isEmpty else {
                return
            }
            guard name != currentProfile.value.header.name else {
                presentationMode.wrappedValue.dismiss()
                return
            }
            guard force || !profileManager.isExistingProfile(withName: name) else {
                isOverwritingExistingProfile = true
                return
            }

            let renamed = currentProfile.value.renamed(to: name)
            profileManager.saveProfile(renamed, isActive: nil)

            presentationMode.wrappedValue.dismiss()
        }
    }
}
