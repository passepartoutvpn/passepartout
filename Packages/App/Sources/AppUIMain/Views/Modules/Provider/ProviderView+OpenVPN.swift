//
//  ProviderView+OpenVPN.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/16/25.
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
import SwiftUI

// MARK: Credentials

extension ProviderView {
    struct OpenVPNCredentialsLink: View {
        var body: some View {
            ProfileLink(
                Strings.Modules.Openvpn.credentials,
                route: ProviderModule.Subroute.openVPNCredentials
            )
        }
    }

    struct OpenVPNCredentialsView: View {

        @EnvironmentObject
        private var apiManager: APIManager

        @ObservedObject
        var draft: ModuleDraft<ProviderModule.Builder>

        @State
        private var builder = OpenVPN.Credentials.Builder()

        @State
        private var providerCustomization: OpenVPN.ProviderCustomization?

        var body: some View {
            Form {
                accountSection
                guidanceSection
            }
            .themeForm()
            .navigationTitle(Strings.Modules.Openvpn.credentials)
            .onLoad(perform: onLoad)
            .onChange(of: builder) { _ in
                saveCredentials()
            }
        }
    }
}

private extension ProviderView.OpenVPNCredentialsView {
    var accountSection: some View {
        Group {
            ThemeTextField(Strings.Global.Nouns.username, text: $builder.username, placeholder: Strings.Placeholders.username)
                .textContentType(.username)

            if !ignoresPassword {
                ThemeSecureField(title: Strings.Global.Nouns.password, text: $builder.password, placeholder: Strings.Placeholders.secret)
                    .textContentType(.password)
                    .onSubmit(saveCredentials)
            }
        }
        .themeSection(footer: guidanceString, forcesFooter: true)
    }

    var guidanceSection: some View {
        providerCustomization.map {
            $0.credentials.url.map {
                Link(Strings.Modules.Openvpn.Credentials.Guidance.link, destination: $0)
            }
        }
    }

    var guidanceString: String? {
        guard draft.module.providerId != nil else {
            return nil
        }
        switch providerCustomization?.credentials.purpose {
        case .specific:
            return Strings.Modules.Openvpn.Credentials.Guidance.specific
        default:
            return Strings.Modules.Openvpn.Credentials.Guidance.web
        }
    }

    var ignoresPassword: Bool {
        providerCustomization?.credentials.options?.contains(.noPassword) ?? false
    }

    func onLoad() {
        guard let providerId = draft.module.providerId,
              let provider = apiManager.provider(withId: providerId) else {
            return
        }
        if let options: OpenVPNProviderTemplate.Options = draft.module.options(for: .openVPN),
           let credentials = options.credentials {
            builder = credentials.builder()
        }
        providerCustomization = provider.customization(for: OpenVPNModule.self)
    }

    func saveCredentials() {
        var options: OpenVPNProviderTemplate.Options = draft.module.options(for: .openVPN) ?? .init()
        options.credentials = builder.build()
        do {
            try draft.module.setOptions(options, for: .openVPN)
        } catch {
            pp_log_g(.app, .error, "Unable to store OpenVPN credentials into options: \(error)")
        }
    }
}

// MARK: - Configuration

extension ProviderView {
    struct OpenVPNConfigurationView: View {
        let configuration: OpenVPN.Configuration.Builder

        var body: some View {
            Form {
                NavigationLink(
                    destination: remotesDestination,
                    label: remotesLinkLabel
                )
                .themeSection(header: Strings.Global.Nouns.connection)

                OpenVPNView.ConfigurationView(
                    isServerPushed: false,
                    configuration: .constant(configuration)
                )
            }
            .themeForm()
            .navigationTitle(Strings.Global.Nouns.configuration)
        }
    }
}

private extension ProviderView.OpenVPNConfigurationView {
    func remotesLinkLabel() -> some View {
        ThemeRow(
            Strings.Modules.Openvpn.remotes,
            value: configuration.remotes?.count.localizedEntries
        )
    }

    func remotesDestination() -> some View {
        Form {
            ForEach(configuration.remotes ?? [], id: \.rawValue) {
                EndpointCardView(endpoint: $0)
            }
        }
        .themeForm()
        .navigationTitle(Strings.Modules.Openvpn.remotes)
    }
}
