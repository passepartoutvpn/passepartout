//
//  OpenVPNView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

struct OpenVPNView: View, ModuleDraftEditing {

    @Environment(\.navigationPath)
    private var path

    @ObservedObject
    var draft: ModuleDraft<OpenVPNModule.Builder>

    let impl: OpenVPNModule.Implementation?

    private let isServerPushed: Bool

    private let providerConfiguration: OpenVPN.Configuration?

    @State
    private var isImporting = false

    @State
    private var paywallReason: PaywallReason?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    init(serverConfiguration: OpenVPN.Configuration) {
        let module = OpenVPNModule.Builder(configurationBuilder: serverConfiguration.builder())
        draft = ModuleDraft(module: module)
        impl = nil
        isServerPushed = true
        providerConfiguration = nil
        assert(module.configurationBuilder != nil, "isServerPushed must imply module.configurationBuilder != nil")
    }

    init(draft: ModuleDraft<OpenVPNModule.Builder>, parameters: ModuleViewParameters) {
        self.draft = draft
        impl = parameters.impl as? OpenVPNModule.Implementation
        isServerPushed = false
        providerConfiguration = try? draft.module.providerSelection?.configuration()
    }

    var body: some View {
        contentView
            .moduleView(draft: draft, withUUID: !isServerPushed)
            .modifier(ImportModifier(
                draft: draft,
                impl: impl,
                isImporting: $isImporting,
                errorHandler: errorHandler
            ))
            .themeAnimation(on: draft.module.providerId, category: .modules)
            .modifier(PaywallModifier(reason: $paywallReason))
            .withErrorHandler(errorHandler)
    }
}

// MARK: - Content

private extension OpenVPNView {

    @ViewBuilder
    var contentView: some View {
        if draft.module.configurationBuilder != nil {
            if !isServerPushed {
                ModuleImportSection(isImporting: $isImporting)
                connectionSection
            }
            ConfigurationView(
                isServerPushed: isServerPushed,
                configuration: $draft.module.configurationBuilder ?? .init(),
                credentialsRoute: ProfileRoute(OpenVPNModule.Subroute.credentials)
            )
        } else if draft.module.providerSelection != nil {
            providerConfiguration
                .map { cfg in
                    Section {
                        cfg.remotes.map {
                            remotesLink(with: $0)
                        }
                        providerConfigurationLink(with: cfg)
                    }
                }
                .modifier(providerModifier)
        } else {
            ModuleImportSection(isImporting: $isImporting)
                .modifier(providerModifier)
        }
    }

    var connectionSection: some View {
        draft.module.configurationBuilder?.remotes.map {
            remotesLink(with: $0)
                .themeSection(header: Strings.Global.Nouns.connection)
        }
    }

    func remotesLink(with remotes: [ExtendedEndpoint]) -> some View {
        NavigationLink(value: ProfileRoute(OpenVPNModule.Subroute.remotes)) {
            Text(Strings.Modules.Openvpn.remotes)
                .themeTrailingValue(remotes.count.localizedEntries)
        }
    }

    func providerConfigurationLink(with configuration: OpenVPN.Configuration) -> some View {
        NavigationLink(Strings.Global.Nouns.configuration, value: ProfileRoute(OpenVPNModule.Subroute.providerConfiguration(configuration)))
    }

    var providerModifier: some ViewModifier {
        ProviderContentModifier(
            providerId: providerId,
            providerPreferences: nil,
            selectedEntity: providerEntity,
            entityDestination: ProfileRoute(OpenVPNModule.Subroute.providerServer),
            paywallReason: $paywallReason,
            providerRows: providerRows
        )
    }

    func providerRows() -> some View {
        ThemeModulePush(caption: Strings.Modules.Openvpn.credentials, route: ProfileRoute(OpenVPNModule.Subroute.credentials))
    }
}

// MARK: - Previews

#Preview {
    let module = OpenVPNModule.Builder(configurationBuilder: .forPreviews)
    return module.preview()
}
