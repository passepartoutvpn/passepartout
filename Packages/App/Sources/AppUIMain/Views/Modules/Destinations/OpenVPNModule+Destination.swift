//
//  OpenVPNModule+Destination.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/12/25.
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

extension OpenVPNView {
    enum Subroute: Hashable {
        case providerServer

        case providerConfiguration(OpenVPN.Configuration)

        case credentials

        case remotes([ExtendedEndpoint])

        case editRemotes
    }
}

extension OpenVPNModule.Builder: ModuleDestinationProviding {
    public func moduleDestination(with parameters: ModuleDestinationParameters, path: Binding<NavigationPath>) -> some ViewModifier {
        DestinationModifier(parameters: parameters, path: path)
    }
}

private struct DestinationModifier: ViewModifier {
    let parameters: ModuleDestinationParameters

    @Binding
    var path: NavigationPath

    @State
    private var preferences = ModulePreferences()

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OpenVPNView.Subroute.self) {
                switch $0 {
                case .providerServer:
                    draft.wrappedValue.providerSelection.map {
                        ProviderServerView(
                            moduleId: parameters.module.id,
                            providerId: $0.id,
                            selectedEntity: $0.entity,
                            filtersWithSelection: true,
                            onSelect: onSelectServer
                        )
                    }

                case .providerConfiguration(let configuration):
                    Form {
                        OpenVPNView.ConfigurationView(
                            isServerPushed: false,
                            configuration: configuration.builder(),
                            credentialsRoute: nil
                        )
                    }
                    .themeForm()
                    .navigationTitle(Strings.Global.Nouns.configuration)

                case .credentials:
                    Form {
                        OpenVPNCredentialsView(
                            profileEditor: parameters.editor,
                            providerId: draft.wrappedValue.providerId,
                            isInteractive: draft.isInteractive,
                            credentials: draft.credentials
                        )
                    }
                    .navigationTitle(Strings.Modules.Openvpn.credentials)
                    .themeForm()
                    .themeAnimation(on: draft.wrappedValue.isInteractive, category: .modules)

                case .remotes(let endpoints):
                    OpenVPNView.RemotesView(
                        endpoints: endpoints,
                        excludedEndpoints: excludedEndpoints,
                        remotesRoute: OpenVPNView.Subroute.editRemotes
                    )

                case .editRemotes:
                    OpenVPNView.EditableRemotesView(remotes: editableRemotesBinding)
                }
            }
            .modifier(ModulePreferencesModifier(
                moduleId: parameters.module.id,
                preferences: preferences
            ))
    }
}

private extension DestinationModifier {
    var draft: Binding<OpenVPNModule.Builder> {
        guard let builder = parameters.module as? OpenVPNModule.Builder else {
            fatalError("Not a OpenVPNModule.Builder")
        }
        return parameters.editor[builder]
    }

    var excludedEndpoints: ObservableList<ExtendedEndpoint> {
        parameters.editor.excludedEndpoints(for: parameters.module.id, preferences: preferences)
    }

    var editableRemotesBinding: Binding<[String]> {
        Binding {
            draft.wrappedValue.configurationBuilder?.remotes?.map(\.rawValue) ?? []
        } set: {
            draft.wrappedValue.configurationBuilder?.remotes = $0.compactMap {
                ExtendedEndpoint(rawValue: $0)
            }
        }
    }

    func onSelectServer(server: ProviderServer, preset: ProviderPreset<OpenVPNProviderTemplate>) {
        draft.wrappedValue.providerEntity = ProviderEntity(server: server, preset: preset)
        resetExcludedEndpointsWithCurrentProviderEntity()
        path.removeLast()
    }

    // filter out exclusions unrelated to current server
    func resetExcludedEndpointsWithCurrentProviderEntity() {
        do {
            let cfg = try draft.wrappedValue.providerSelection?.configuration()
            parameters.editor.profile.attributes.editPreferences(inModule: parameters.module.id) {
                if let cfg {
                    $0.excludedEndpoints = Set(cfg.remotes?.filter {
                        preferences.isExcludedEndpoint($0)
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
