//
//  OpenVPNView+Credentials.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/1/24.
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

import PassepartoutKit
import SwiftUI

extension OpenVPNView {
    struct CredentialsView: View {

        @EnvironmentObject
        private var iapManager: IAPManager

        @Binding
        var isInteractive: Bool

        @Binding
        var credentials: OpenVPN.Credentials?

        var isAuthenticating = false

        @State
        private var builder = OpenVPN.Credentials.Builder()

        @State
        private var otp = ""

        @State
        private var paywallReason: PaywallReason?

        var body: some View {
            Form {
                restrictedArea
                inputSection
            }
            .themeAnimation(on: isInteractive, category: .modules)
            .themeManualInput()
            .themeForm()
            .navigationTitle(Strings.Modules.Openvpn.credentials)
            .onLoad {
                builder = credentials?.builder() ?? OpenVPN.Credentials.Builder()
            }
            .onChange(of: builder) {
                if isEligibleForInteractiveLogin, isAuthenticating {
                    credentials = $0.buildForAuthentication(otp: otp)
                } else {
                    credentials = $0.build()
                }
            }
            .onChange(of: otp) {
                credentials = builder.buildForAuthentication(otp: $0)
            }
            .modifier(PaywallModifier(reason: $paywallReason))
        }
    }
}

private extension OpenVPNView.CredentialsView {
    var isEligibleForInteractiveLogin: Bool {
        iapManager.isEligible(for: .interactiveLogin)
    }

    var otpMethods: [OpenVPN.Credentials.OTPMethod] {
        [.none, .append, .encode]
    }

    @ViewBuilder
    var restrictedArea: some View {
        switch iapManager.paywallReason(forFeature: .interactiveLogin) {
        case .purchase(let appFeature):
            Button(Strings.Modules.Openvpn.Purchase.interactive) {
                paywallReason = .purchase(appFeature)
            }

        case .restricted:
            EmptyView()

        default:
            if !isAuthenticating {
                interactiveSection
            }
        }
    }

    var interactiveSection: some View {
        Group {
            Toggle(Strings.Modules.Openvpn.Credentials.interactive, isOn: $isInteractive)

            if isInteractive {
                Picker(Strings.Unlocalized.otp, selection: $builder.otpMethod) {
                    ForEach(otpMethods, id: \.self) {
                        Text($0.localizedDescription(style: .entity))
                    }
                }
            }
        }
        .themeSectionWithFooter(interactiveFooter)
    }

    var interactiveFooter: String? {
        if isInteractive {
            return [
                Strings.Modules.Openvpn.Credentials.Interactive.footer,
                builder.otpMethod.localizedDescription(style: .approachDescription)
            ].joined(separator: " ")
        }
        return nil
    }

    var inputSection: some View {
        Group {
            ThemeTextField(Strings.Global.username, text: $builder.username, placeholder: Strings.Placeholders.username)
                .textContentType(.username)
            ThemeSecureField(title: Strings.Global.password, text: $builder.password, placeholder: Strings.Placeholders.secret)
                .textContentType(.password)

            if isEligibleForInteractiveLogin, isAuthenticating && builder.otpMethod != .none {
                ThemeSecureField(title: Strings.Unlocalized.otp, text: $otp, placeholder: Strings.Placeholders.secret)
                    .textContentType(.oneTimeCode)
            }
        }
        .themeSectionWithFooter(inputFooter)
    }

    var inputFooter: String? {
        if isAuthenticating {
            return builder.otpMethod.localizedDescription(style: .approachDescription)
        }
        return nil
    }
}

#Preview {

    @State
    var credentials: OpenVPN.Credentials?

    @State
    var isInteractive = false

    return NavigationStack {
        OpenVPNView.CredentialsView(
            isInteractive: $isInteractive,
            credentials: $credentials
        )
        .withMockEnvironment()
    }
}
