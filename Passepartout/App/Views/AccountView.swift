//
//  AccountView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/11/22.
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

struct AccountView: View {
    enum Field {
        case username

        case password

        case seed
    }

    @ObservedObject private var providerManager: ProviderManager

    private let providerName: ProviderName?

    private let vpnProtocol: VPNProtocolType

    @Binding private var account: Profile.Account

    private let saveAnyway: Bool

    private let onSave: (() -> Void)?

    @State private var liveAccount = Profile.Account()

    @FocusState private var focusedField: Field?

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
                    .focused($focusedField, equals: .username)
                    .themeRawTextStyle()
                    .withLeadingText(L10n.Account.Items.Username.caption)

                switch liveAccount.authenticationMethod {
                case nil, .persistent, .interactive:
                    if liveAccount.authenticationMethod == .interactive {
                        EmptyView()
                    } else {
                        themeSecureField(L10n.Account.Items.Password.placeholder, text: $liveAccount.password)
                            .focused($focusedField, equals: .password)
                            .withLeadingText(L10n.Account.Items.Password.caption)
                    }

                case .totp:
                    // TODO: interactive, scan QR code
                    themeSecureField(L10n.Account.Items.Password.placeholder, text: $liveAccount.password, contentType: .oneTimeCode)
                        .focused($focusedField, equals: .seed)
                        .withLeadingText(L10n.Account.Items.Seed.caption)
                }
            } footer: {
                metadata?.localizedDescription(optionalStyle: .guidance).map {
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
        }.toolbar {
            CopySavingButton(
                original: $account,
                copy: $liveAccount,
                mapping: \.stripped,
                label: themeSaveButtonLabel,
                saveAnyway: saveAnyway,
                onSave: onSave
            )
        }.onAppear {
            focusedField = .username
        }.navigationTitle(L10n.Account.title)
    }
}

// MARK: -

private extension AccountView {
    var usernamePlaceholder: String? {
        guard let name = providerName else {
            return nil
        }
        return providerManager.defaultUsername(name, vpnProtocol: vpnProtocol)
    }

    var metadata: ProviderMetadata? {
        guard let name = providerName else {
            return nil
        }
        return providerManager.provider(withName: name)
    }
}

// MARK: -

private extension AccountView {
    func openGuidanceURL(_ url: URL) {
        URL.open(url)
    }
}
