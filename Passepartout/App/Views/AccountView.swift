//
//  AccountView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/11/22.
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

struct AccountView: View {
    @ObservedObject private var providerManager: ProviderManager

    private let providerName: ProviderName?

    private let vpnProtocol: VPNProtocolType

    @Binding private var account: Profile.Account

    private let saveAnyway: Bool

    private let onSave: (() -> Void)?

    @State private var liveAccount = Profile.Account()

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
            // TODO: interactive, re-enable after fixing
//            Section {
//                // TODO: interactive, l10n
//                themeTextPicker(L10n.Global.Strings.authentication, selection: $liveAccount.authenticationMethod ?? .persistent, values: [
//                    .persistent,
//                    .interactive
////                    .totp // TODO: interactive, support OTP-based authentication
//                ], description: \.localizedDescription)
//            }
            Section {
                TextField(usernamePlaceholder ?? L10n.Account.Items.Username.placeholder, text: $liveAccount.username)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .themeRawTextStyle()
                    .withLeadingText(L10n.Account.Items.Username.caption)

                switch liveAccount.authenticationMethod {
                case nil, .persistent, .interactive:
                    if liveAccount.authenticationMethod == .interactive {
                        EmptyView()
                    } else {
                        themeSecureField(L10n.Account.Items.Password.placeholder, text: $liveAccount.password)
                            .withLeadingText(L10n.Account.Items.Password.caption)
                    }

                // TODO: interactive, scan QR code
                case .totp:
                    themeSecureField(L10n.Account.Items.Password.placeholder, text: $liveAccount.password, contentType: .oneTimeCode)
                        .withLeadingText(L10n.Account.Items.Seed.caption)
                }
            } footer: {
                metadata?.localizedGuidanceString.map {
                    Text($0)
                }
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

private extension Profile.Account.AuthenticationMethod {
    var localizedDescription: String {
        switch self {
        case .persistent:
            return L10n.Account.Items.AuthenticationMethod.persistent

        case .interactive:
            return L10n.Account.Items.AuthenticationMethod.interactive

        case .totp:
            return Unlocalized.Other.totp
        }
    }
}
