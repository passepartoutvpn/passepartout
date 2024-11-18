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

import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI

public struct OpenVPNCredentialsView: View {
    private enum Field: Hashable {
        case username

        case password

        case otp
    }

    @EnvironmentObject
    private var iapManager: IAPManager

    @Binding
    private var isInteractive: Bool

    @Binding
    private var credentials: OpenVPN.Credentials?

    private let isAuthenticating: Bool

    private let onSubmit: (() -> Void)?

    @State
    private var builder = OpenVPN.Credentials.Builder()

    @State
    private var paywallReason: PaywallReason?

    @FocusState
    private var focusedField: Field?

    public init(
        isInteractive: Binding<Bool>,
        credentials: Binding<OpenVPN.Credentials?>,
        isAuthenticating: Bool = false,
        onSubmit: (() -> Void)? = nil
    ) {
        _isInteractive = isInteractive
        _credentials = credentials
        self.isAuthenticating = isAuthenticating
        self.onSubmit = onSubmit
    }

    public var body: some View {
        Group {
            if !isAuthenticating {
                interactiveSection
            }
            inputSection
        }
        .themeManualInput()
        .modifier(PaywallModifier(reason: $paywallReason))
        .onLoad {
            builder = credentials?.builder() ?? OpenVPN.Credentials.Builder()
            builder.otp = nil
            if isAuthenticating {
                switch builder.otpMethod {
                case .none:
                    focusedField = .username

                default:
                    focusedField = .otp
                }
            }
        }
        .onChange(of: builder) {
            var copy = $0
            if isEligibleForInteractiveLogin {
                copy.otp = copy.otp ?? ""
            } else {
                copy.otpMethod = .none
                copy.otp = nil
            }
            credentials = copy.build()
        }
    }
}

private extension OpenVPNCredentialsView {
    var isEligibleForInteractiveLogin: Bool {
        iapManager.isEligible(for: .interactiveLogin)
    }

    var requiredFeatures: Set<AppFeature>? {
        isInteractive ? [.interactiveLogin] : nil
    }

    var otpMethods: [OpenVPN.Credentials.OTPMethod] {
        [.none, .append, .encode]
    }

    var interactiveSection: some View {
        Group {
            Toggle(isOn: $isInteractive) {
                HStack {
                    Text(Strings.Modules.Openvpn.Credentials.interactive)
                    PurchaseRequiredButton(features: requiredFeatures, paywallReason: $paywallReason)
                }
            }
            .themeRow(footer: interactiveFooter)

            if isInteractive {
                Picker(Strings.Unlocalized.otp, selection: $builder.otpMethod) {
                    ForEach(otpMethods, id: \.self) {
                        Text($0.localizedDescription(style: .entity))
                    }
                }
            }
        }
        .themeSection(footer: interactiveFooter)
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
            if !isAuthenticating || builder.otpMethod == .none {
                usernameField
                passwordField
            }
            if isEligibleForInteractiveLogin, isAuthenticating, builder.otpMethod != .none {
                otpField
            }
        }
        .themeSection(footer: inputFooter)
    }

    var inputFooter: String? {
        if isAuthenticating {
            return builder.otpMethod.localizedDescription(style: .approachDescription)
                .nilIfEmpty
        }
        return nil
    }

    var usernameField: some View {
        ThemeTextField(Strings.Global.username, text: $builder.username, placeholder: Strings.Placeholders.username)
            .textContentType(.username)
            .focused($focusedField, equals: .username)
    }

    var passwordField: some View {
        ThemeSecureField(title: Strings.Global.password, text: $builder.password, placeholder: Strings.Placeholders.secret)
            .textContentType(.password)
            .focused($focusedField, equals: .password)
            .onSubmit {
                if builder.otpMethod == .none {
                    onSubmit?()
                }
            }
    }

    var otpField: some View {
        ThemeSecureField(
            title: Strings.Unlocalized.otp,
            text: $builder.otp ?? "",
            placeholder: Strings.Placeholders.secret
        )
        .textContentType(.oneTimeCode)
        .focused($focusedField, equals: .otp)
        .onSubmit {
            if builder.otpMethod != .none {
                onSubmit?()
            }
        }
    }
}

#Preview {
    struct ContentView: View {

        @State
        private var credentials: OpenVPN.Credentials?

        @State
        private var isInteractive = true

        var body: some View {
            NavigationStack {
                OpenVPNCredentialsView(
                    isInteractive: $isInteractive,
                    credentials: $credentials
                )
            }
        }
    }

    return ContentView()
        .withMockEnvironment()
}
