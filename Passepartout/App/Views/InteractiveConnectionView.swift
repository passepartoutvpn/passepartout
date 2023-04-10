//
//  InteractiveConnectionView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/15/23.
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

struct InteractiveConnectionView: View {
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject private var profileManager: ProfileManager

    @ObservedObject private var vpnManager: VPNManager

    private let profile: Profile

    @State private var password = ""

    init(profile: Profile) {
        profileManager = .shared
        vpnManager = .shared
        self.profile = profile
    }

    var body: some View {
        List {
            Section {
                TextField(L10n.Account.Items.Username.placeholder, text: .constant(profile.account.username))
                    .withLeadingText(L10n.Account.Items.Username.caption)
                    .disabled(true)

                themeSecureField(L10n.Account.Items.Password.placeholder, text: $password)
                    .withLeadingText(L10n.Account.Items.Password.caption)
            } header: {
                Text(L10n.Account.title)
            }
        }.toolbar {
            themeCloseItem(presentationMode: presentationMode)
            ToolbarItem(placement: .confirmationAction) {
                Button(action: saveAccount) {
                    Text(L10n.Global.Strings.connect)
                }
            }
        }.navigationTitle(profile.header.name)
    }

    private func saveAccount() {
        Task {
            try? await vpnManager.connect(with: profile.id, newPassword: password)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
