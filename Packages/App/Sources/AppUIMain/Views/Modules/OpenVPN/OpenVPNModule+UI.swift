//
//  OpenVPNModule+UI.swift
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
import UILibrary

extension OpenVPNModule.Builder: ModuleViewProviding {
    public func moduleView(with parameters: ModuleViewParameters) -> some View {
        OpenVPNView(draft: parameters.editor[self], parameters: parameters)
    }
}

// MARK: - Destination

extension OpenVPNModule {
    enum Subroute: Hashable {
        case credentials

        case remotes
    }
}

extension OpenVPNModule.Builder: ModuleDestinationProviding {
    public func handlesRoute(_ route: AnyHashable) -> Bool {
        route is OpenVPNModule.Subroute
    }

    public func moduleDestination(
        for route: AnyHashable,
        path: Binding<NavigationPath>,
        editor: ProfileEditor
    ) -> some View {
        (route as? OpenVPNModule.Subroute)
            .map {
                DestinationView(route: $0, path: path, editor: editor, draft: editor[self])
            }
    }
}

private struct DestinationView: View {
    let route: OpenVPNModule.Subroute

    @Binding
    var path: NavigationPath

    @ObservedObject
    var editor: ProfileEditor

    @ObservedObject
    var draft: ModuleDraft<OpenVPNModule.Builder>

    @StateObject
    private var preferences = ModulePreferences()

    var body: some View {
        Group {
            switch route {
            case .credentials:
                Form {
                    OpenVPNCredentialsGroup(draft: draft)
                }
                .navigationTitle(Strings.Modules.Openvpn.credentials)
                .themeForm()
                .themeAnimation(on: draft.module.isInteractive, category: .modules)

            case .remotes:
                OpenVPNView.RemotesView(
                    configuration: configurationBuilderBinding,
                    excludedEndpoints: excludedEndpoints,
                    isEditable: true
                )
            }
        }
        .modifier(ModulePreferencesModifier(
            moduleId: draft.module.id,
            preferences: preferences
        ))
    }
}

private extension DestinationView {
    var configurationBuilderBinding: Binding<OpenVPN.Configuration.Builder> {
        Binding {
            draft.module.configurationBuilder ?? OpenVPN.Configuration.Builder()
        } set: {
            draft.module.configurationBuilder = $0
        }
    }

    var excludedEndpoints: ObservableList<ExtendedEndpoint> {
        editor.excludedEndpoints(for: draft.module.id, preferences: preferences)
    }
}

// MARK: - Shortcuts

extension OpenVPNModule.Builder: ModuleShortcutsProviding {
    public var isVisible: Bool {
        configurationBuilder?.authUserPass == true
    }

    @ViewBuilder
    public func moduleShortcutsView(editor: ProfileEditor, path: Binding<NavigationPath>) -> some View {
        if configurationBuilder?.authUserPass == true {
            ProfileLink(
                Strings.Modules.Openvpn.credentials,
                route: OpenVPNModule.Subroute.credentials
            )
        }
    }
}
