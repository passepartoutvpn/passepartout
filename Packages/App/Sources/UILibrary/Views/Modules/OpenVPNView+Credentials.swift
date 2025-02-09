//
//  OpenVPNView+Credentials.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/1/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

    @EnvironmentObject
    private var apiManager: APIManager

    @ObservedObject
    private var profileEditor: ProfileEditor

    private let providerId: ProviderID?

    @Binding
    private var isInteractive: Bool

    @Binding
    private var credentials: OpenVPN.Credentials?

    private let isAuthenticating: Bool

    private let onSubmit: (() -> Void)?

    @State
    private var builder = OpenVPN.Credentials.Builder()

    @State
    private var providerCustomization: OpenVPN.ProviderCustomization?

    @State
    private var paywallReason: PaywallReason?

    @FocusState
    private var focusedField: Field?

    public init(
        profileEditor: ProfileEditor,
        providerId: ProviderID?,
        isInteractive: Binding<Bool>,
        credentials: Binding<OpenVPN.Credentials?>,
        isAuthenticating: Bool = false,
        onSubmit: (() -> Void)? = nil
    ) {
        self.profileEditor = profileEditor
        self.providerId = providerId
        _isInteractive = isInteractive
        _credentials = credentials
        self.isAuthenticating = isAuthenticating
        self.onSubmit = onSubmit
    }

    public var body: some View {
        debugChanges()
        return Group {
            interactiveSection
            inputSection
            guidanceSection
        }
        .themeManualInput()
        .themeAnimation(on: isInteractive, category: .modules)
        .themeAnimation(on: builder, category: .modules)
        .onLoad(perform: onLoad)
        .onChange(of: builder, perform: onChange)
        .modifier(PaywallModifier(reason: $paywallReason))
    }
}

private extension OpenVPNCredentialsView {
    var interactiveSection: some View {
        Group {
            Toggle(isOn: $isInteractive) {
                HStack {
                    Text(Strings.Modules.Openvpn.Credentials.interactive)
                    PurchaseRequiredView(
                        requiring: requiredFeatures,
                        reason: $paywallReason
                    )
                }
            }
            .themeRowWithSubtitle(interactiveFooter)

            if isInteractive && !isAuthenticating {
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
                if !ignoresPassword {
                    passwordField
                }
            }
            if isAuthenticating, builder.otpMethod != .none {
                otpField
            }
        }
        .themeSection(footer: inputFooter, forcesFooter: true)
    }

    @ViewBuilder
    var guidanceSection: some View {
        if let url = providerCustomization?.credentials.url {
            Link(Strings.Modules.Openvpn.Credentials.Guidance.link, destination: url)
        }
    }

    var inputFooter: String? {
        if isAuthenticating {
            return builder.otpMethod.localizedDescription(style: .approachDescription)
                .nilIfEmpty
        } else if providerId != nil {
            switch providerCustomization?.credentials.purpose {
            case .specific:
                return Strings.Modules.Openvpn.Credentials.Guidance.specific
            default:
                return Strings.Modules.Openvpn.Credentials.Guidance.web
            }
        }
        return nil
    }

    var usernameField: some View {
        ThemeTextField(Strings.Global.Nouns.username, text: $builder.username, placeholder: Strings.Placeholders.username)
            .textContentType(.username)
            .focused($focusedField, equals: .username)
    }

    var passwordField: some View {
        ThemeSecureField(title: Strings.Global.Nouns.password, text: $builder.password, placeholder: Strings.Placeholders.secret)
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

private extension OpenVPNCredentialsView {
    var requiredFeatures: Set<AppFeature>? {
        isInteractive && builder.otpMethod != .none ? [.otp] : nil
    }

    var otpMethods: [OpenVPN.Credentials.OTPMethod] {
        [.none, .append, .encode]
    }

    var ignoresPassword: Bool {
        providerCustomization?.credentials.options?.contains(.noPassword) ?? false
    }

    func onLoad() {
        if let providerId, let provider = apiManager.provider(withId: providerId) {
            providerCustomization = provider.customization(for: OpenVPNProviderTemplate.self)
        }
        builder = credentials?.builder() ?? OpenVPN.Credentials.Builder()
        if ignoresPassword {
            builder.password = ""
        }
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

    func onChange(_ builder: OpenVPN.Credentials.Builder) {
        credentials = builder.build()
    }
}

// MARK: - Previews

#Preview {
    struct ContentView: View {

        @State
        private var credentials: OpenVPN.Credentials?

        @State
        private var isInteractive = true

        var body: some View {
            NavigationStack {
                OpenVPNCredentialsView(
                    profileEditor: ProfileEditor(),
                    providerId: nil,
                    isInteractive: $isInteractive,
                    credentials: $credentials
                )
            }
        }
    }

    return ContentView()
        .withMockEnvironment()
}
