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

import AppLibrary
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

    private var isAuthenticating = false

    @State
    private var builder = OpenVPN.Credentials.Builder()

    @State
    private var paywallReason: PaywallReason?

    @FocusState
    private var focusedField: Field?

    public init(
        isInteractive: Binding<Bool>,
        credentials: Binding<OpenVPN.Credentials?>,
        isAuthenticating: Bool = false
    ) {
        _isInteractive = isInteractive
        _credentials = credentials
        self.isAuthenticating = isAuthenticating
    }

    public var body: some View {
        Group {
            restrictedArea
            inputSection
        }
        .themeManualInput()
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

    var otpMethods: [OpenVPN.Credentials.OTPMethod] {
        [.none, .append, .encode]
    }

    @ViewBuilder
    var restrictedArea: some View {
        switch iapManager.paywallReason(forFeature: .interactiveLogin) {
        case .purchase(let appFeature):
            Button(Strings.Modules.Openvpn.Credentials.Interactive.purchase) {
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
                ThemeTextField(Strings.Global.username, text: $builder.username, placeholder: Strings.Placeholders.username)
                    .textContentType(.username)
                    .focused($focusedField, equals: .username)

                ThemeSecureField(title: Strings.Global.password, text: $builder.password, placeholder: Strings.Placeholders.secret)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
            }
            if isEligibleForInteractiveLogin, isAuthenticating, builder.otpMethod != .none {
                ThemeSecureField(
                    title: Strings.Unlocalized.otp,
                    text: $builder.otp ?? "",
                    placeholder: Strings.Placeholders.secret
                )
                .textContentType(.oneTimeCode)
                .focused($focusedField, equals: .otp)
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
}

#Preview {

    @State
    var credentials: OpenVPN.Credentials?

    @State
    var isInteractive = true

    return NavigationStack {
        OpenVPNCredentialsView(
            isInteractive: $isInteractive,
            credentials: $credentials
        )
        .withMockEnvironment()
    }
}
