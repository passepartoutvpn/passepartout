//
//  ProviderModule+UI.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/15/25.
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
import AppLibrary

extension ProviderModule.Builder: ModuleViewProviding {
    public func moduleView(with parameters: ModuleViewParameters) -> some View {
        ProviderView(draft: parameters.editor[self], parameters: parameters)
    }
}

// MARK: - Destination

extension ProviderModule {
    enum Subroute: Hashable {
        case server

//        case preset

        case openVPNCredentials
    }
}

extension ProviderModule.Builder: ModuleDestinationProviding {
    public func handlesRoute(_ route: AnyHashable) -> Bool {
        route is ProviderModule.Subroute
    }

    public func moduleDestination(
        for route: AnyHashable,
        path: Binding<NavigationPath>,
        editor: ProfileEditor
    ) -> some View {
        (route as? ProviderModule.Subroute)
            .map {
                DestinationView(route: $0, draft: editor[self], path: path)
            }
    }
}

private struct DestinationView: View {
    let route: ProviderModule.Subroute

    @ObservedObject
    var draft: ModuleDraft<ProviderModule.Builder>

    @Binding
    var path: NavigationPath

    var body: some View {
        Group {
            switch route {
            case .server:
                module.map {
                    ProviderServerView(
                        module: $0,
                        onSelect: {
                            draft.module.entity = $0
                            path.removeLast()
                        }
                    )
                }

            case .openVPNCredentials:
                ProviderView.OpenVPNCredentialsView(draft: draft)
            }
        }
    }

    // FIXME: #1470, heavy data copy in SwiftUI
    private var module: ProviderModule? {
        try? draft.module.tryBuild()
    }
}

// MARK: - Shortcuts

extension ProviderModule.Builder: ModuleShortcutsProviding {
    public var isVisible: Bool {
        providerId != nil && providerModuleType != nil
    }

    @ViewBuilder
    public func moduleShortcutsView(editor: ProfileEditor, path: Binding<NavigationPath>) -> some View {
        if let providerId {
            ProviderNameRow(id: providerId)
        }
        ProviderServerLink(entity: entity)
        switch providerModuleType {
        case .openVPN:
            ProviderView.OpenVPNCredentialsLink()
        default:
            EmptyView()
        }
    }
}
