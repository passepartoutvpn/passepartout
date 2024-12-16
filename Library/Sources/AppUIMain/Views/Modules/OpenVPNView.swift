//
//  OpenVPNView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    init(serverConfiguration: OpenVPN.Configuration) {
        module = OpenVPNModule.Builder(configurationBuilder: serverConfiguration.builder())
        editor = ProfileEditor(modules: [module])
        modulePreferences = ModulePreferences()
        assert(module.configurationBuilder != nil, "isServerPushed must imply module.configurationBuilder != nil")
        impl = nil
        isServerPushed = true
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
            .modifier(ImportModifier(
                draft: draft,
                impl: impl,
                isImporting: $isImporting,
                errorHandler: errorHandler
            ))
            .navigationDestination(for: Subroute.self, destination: destination)
            .themeAnimation(on: draft.wrappedValue.providerId, category: .modules)
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
        Button(Strings.Modules.General.Rows.importFromFile.withTrailingDots) {
            isImporting = true
        }
    }

    var providerModifier: some ViewModifier {
        VPNProviderContentModifier(
            providerId: providerId,
            providerPreferences: nil,
            selectedEntity: providerEntity,
            entityDestination: Subroute.providerServer,
            providerRows: {
                moduleGroup(for: providerAccountRows)
            }
        )
    }

    var providerAccountRows: [ModuleRow]? {
        [.push(caption: Strings.Modules.Openvpn.credentials, route: HashableRoute(Subroute.credentials))]
    }
}

// MARK: - Destinations

private extension OpenVPNView {
    enum Subroute: Hashable {
        case providerServer

        case providerConfiguration(OpenVPN.Configuration)

        case credentials
    }

    @ViewBuilder
    func destination(for route: Subroute) -> some View {
        switch route {
        case .providerServer:
            draft.wrappedValue.providerSelection.map {
                VPNProviderServerView(
                    moduleId: module.id,
                    providerId: $0.id,
                    selectedEntity: $0.entity,
                    filtersWithSelection: true,
                    onSelect: onSelectServer
                )
            }

        case .providerConfiguration(let configuration):
            Form {
                ConfigurationView(
                    isServerPushed: false,
                    configuration: configuration.builder(),
                    credentialsRoute: nil,
                    excludedEndpoints: excludedEndpoints
                )
            }
            .themeForm()
            .navigationTitle(Strings.Global.Nouns.configuration)

        case .credentials:
            Form {
                OpenVPNCredentialsView(
                    providerId: draft.wrappedValue.providerId,
                    isInteractive: draft.isInteractive,
                    credentials: draft.credentials
                )
            }
            .navigationTitle(Strings.Modules.Openvpn.credentials)
            .themeForm()
            .themeAnimation(on: draft.wrappedValue.isInteractive, category: .modules)
        }
    }
}

// MARK: - Logic

private extension OpenVPNView {
    var excludedEndpoints: ObservableList<ExtendedEndpoint> {
        editor.excludedEndpoints(for: module.id, preferences: modulePreferences)
    }

    func onSelectServer(server: VPNServer, preset: VPNPreset<OpenVPN.Configuration>) {
        draft.wrappedValue.providerEntity = VPNEntity(server: server, preset: preset)
        resetExcludedEndpointsWithCurrentProviderEntity()
        path.wrappedValue.removeLast()
    }

    // filter out exclusions unrelated to current server
    func resetExcludedEndpointsWithCurrentProviderEntity() {
        do {
            let cfg = try draft.wrappedValue.providerSelection?.configuration()
            editor.profile.attributes.editPreferences(inModule: module.id) {
                if let cfg {
                    $0.excludedEndpoints = Set(cfg.remotes?.filter {
                        modulePreferences.isExcludedEndpoint($0)
                    } ?? [])
                } else {
                    $0.excludedEndpoints = []
                }
            }
        } catch {
            pp_log(.app, .error, "Unable to build provider configuration for excluded endpoints: \(error)")
        }
    }
}

// MARK: - Previews

#Preview {
    let module = OpenVPNModule.Builder(configurationBuilder: .forPreviews)
    return module.preview(title: "OpenVPN")
}
