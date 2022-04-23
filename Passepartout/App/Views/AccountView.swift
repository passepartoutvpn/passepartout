//
//  AccountView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/11/22.
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

extension Profile.Account: CopySavingModel {
}

struct AccountView: View {
    @ObservedObject private var providerManager: ProviderManager
    
    private let providerName: ProviderName?
    
    private let vpnProtocol: VPNProtocolType
    
    @Binding private var account: Profile.Account
    
    private let saveAnyway: Bool
    
    private let onSave: (() -> Void)?

    @State private var liveAccount = Profile.Account()
    
    @State private var isPasswordRevealed = false
    
    init(
        providerName: ProviderName?,
        vpnProtocol: VPNProtocolType,
        account: Binding<Profile.Account>,
        saveAnyway: Bool = false,
        onSave: (() -> Void)? = nil
    ) {
        providerManager = .shared
        self.providerName = providerName
        self.vpnProtocol = vpnProtocol
        _account = account
        self.saveAnyway = saveAnyway
        self.onSave = onSave
    }
    
    var body: some View {
        List {
            Section(
                footer: metadata?.localizedGuidanceString.map {
                    Text($0)
                }
            ) {
                TextField(usernamePlaceholder ?? L10n.Account.Items.Username.placeholder, text: $liveAccount.username)
                    .textContentType(.username)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .withLeadingText(L10n.Account.Items.Username.caption)

                RevealingSecureField(L10n.Account.Items.Password.placeholder, text: $liveAccount.password) {
                    themeConceilImage.asSystemImage
                        .themeAccentForegroundStyle()
                } revealImage: {
                    themeRevealImage.asSystemImage
                        .themeAccentForegroundStyle()
                }.textContentType(.password)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .withLeadingText(L10n.Account.Items.Password.caption)
            }
            if vpnProtocol == .openVPN {
                metadata?.openVPNGuidanceURL.map { guidanceURL in
                    Section {
                        Button(L10n.Account.Items.OpenGuide.caption) {
                            openGuidanceURL(guidanceURL)
                        }
                    }
                }
            }
        }.navigationTitle(L10n.Account.title)
        .toolbar {
            CopySavingButton(
                original: $account,
                copy: $liveAccount,
                mapping: \.stripped,
                label: themeSaveButtonLabel,
                saveAnyway: saveAnyway,
                onSave: onSave
            )
        }
    }
    
    private func openGuidanceURL(_ url: URL) {
        URL.openURL(url)
    }
}

// MARK: Provider

extension AccountView {
    private var usernamePlaceholder: String? {
        guard let name = providerName else {
            return nil
        }
        return providerManager.defaultUsername(name, vpnProtocol: vpnProtocol)
    }

    private var metadata: ProviderMetadata? {
        guard let name = providerName else {
            return nil
        }
        return providerManager.provider(withName: name)
    }
}
