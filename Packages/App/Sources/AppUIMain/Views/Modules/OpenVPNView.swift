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

    let module: OpenVPNModule.Builder

    @ObservedObject
    var editor: ProfileEditor

    @ObservedObject
    var modulePreferences: ModulePreferences

    let impl: OpenVPNModule.Implementation?

    private let isServerPushed: Bool

    @State
    private var isImporting = false

    @State
    private var paywallReason: PaywallReason?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    init(serverConfiguration: OpenVPN.Configuration) {
        module = OpenVPNModule.Builder(configurationBuilder: serverConfiguration.builder())
        editor = ProfileEditor(modules: [module])
        modulePreferences = ModulePreferences()
        impl = nil
        isServerPushed = true
        assert(module.configurationBuilder != nil, "isServerPushed must imply module.configurationBuilder != nil")
    }

    init(module: OpenVPNModule.Builder, parameters: ModuleViewParameters) {
        self.module = module
        editor = parameters.editor
        modulePreferences = parameters.preferences
        impl = parameters.impl as? OpenVPNModule.Implementation
        isServerPushed = false
    }

    var body: some View {
        contentView
            .moduleView(editor: editor, draft: draft.wrappedValue)
            .modifier(module.moduleDestination(
                with: .init(
                    editor: editor,
                    module: module,
                    preferences: modulePreferences,
                    impl: impl
                ),
                path: path
            ))
            .modifier(ImportModifier(
                draft: draft,
                impl: impl,
                isImporting: $isImporting,
                errorHandler: errorHandler
            ))
            .themeAnimation(on: draft.wrappedValue.providerId, category: .modules)
            .modifier(PaywallModifier(reason: $paywallReason))
            .withErrorHandler(errorHandler)
    }
}

// MARK: - Content

private extension OpenVPNView {

    @ViewBuilder
    var contentView: some View {
        if let configuration = draft.wrappedValue.configurationBuilder {
            ConfigurationView(
                isServerPushed: isServerPushed,
                configuration: configuration,
                credentialsRoute: Subroute.credentials,
                remotesRoute: Subroute.editRemotes,
                excludedEndpoints: excludedEndpoints
            )
        } else {
            emptyConfigurationView
                .modifier(providerModifier)
        }
    }

    @ViewBuilder
    var emptyConfigurationView: some View {
        if draft.wrappedValue.providerSelection == nil {
            importButton
        } else if let configuration = try? draft.wrappedValue.providerSelection?.configuration() {
            providerConfigurationLink(with: configuration)
        }
    }

    func providerConfigurationLink(with configuration: OpenVPN.Configuration) -> some View {
        NavigationLink(Strings.Global.Nouns.configuration, value: Subroute.providerConfiguration(configuration))
    }

    var importButton: some View {
        Button(Strings.Modules.General.Rows.importFromFile.forMenu) {
            isImporting = true
        }
    }

    var providerModifier: some ViewModifier {
        ProviderContentModifier(
            providerId: providerId,
            providerPreferences: nil,
            selectedEntity: providerEntity,
            entityDestination: Subroute.providerServer,
            paywallReason: $paywallReason,
            providerRows: {
                moduleGroup(for: providerAccountRows)
            }
        )
    }

    var providerAccountRows: [ModuleRow]? {
        [.push(caption: Strings.Modules.Openvpn.credentials, route: HashableRoute(Subroute.credentials))]
    }
}

private extension OpenVPNView {
    var excludedEndpoints: ObservableList<ExtendedEndpoint> {
        editor.excludedEndpoints(for: module.id, preferences: modulePreferences)
    }
}

// MARK: - Previews

#Preview {
    let module = OpenVPNModule.Builder(configurationBuilder: .forPreviews)
    return module.preview(title: "OpenVPN")
}
