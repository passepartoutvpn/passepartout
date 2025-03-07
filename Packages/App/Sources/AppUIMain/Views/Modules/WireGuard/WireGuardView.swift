//
//  WireGuardView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/31/24.
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

struct WireGuardView: View, ModuleDraftEditing {

    @Environment(\.navigationPath)
    private var path

    @ObservedObject
    var draft: ModuleDraft<WireGuardModule.Builder>

    let impl: WireGuardModule.Implementation?

    @State
    private var paywallReason: PaywallReason?

    @State
    private var isImporting = false

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    init(draft: ModuleDraft<WireGuardModule.Builder>, parameters: ModuleViewParameters) {
        self.draft = draft
        impl = parameters.impl as? WireGuardModule.Implementation
    }

    var body: some View {
        contentView
            .moduleView(draft: draft)
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

private extension WireGuardView {

    @ViewBuilder
    var contentView: some View {
        if draft.module.configurationBuilder != nil {
            Section {
                importButton
            }
            ConfigurationView(
                configuration: $draft.module.configurationBuilder ?? impl.map {
                    .init(keyGenerator: $0.keyGenerator)
                } ?? .init(privateKey: ""),
                keyGenerator: impl?.keyGenerator
            )
        } else {
            importButton
                .modifier(providerModifier)
        }
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
            entityDestination: ProfileRoute(Subroute.providerServer),
            paywallReason: $paywallReason,
            providerRows: providerRows
        )
    }

    func providerRows() -> some View {
        ThemeModulePush(caption: Strings.Global.Nouns.privateKey, route: ProfileRoute(Subroute.providerKey))
    }
}

private extension WireGuardView {
    func onSelectServer(
        server: ProviderServer,
        heuristic: ProviderHeuristic?,
        preset: ProviderPreset<WireGuardProviderTemplate>
    ) {
        draft.module.providerEntity = ProviderEntity(
            server: server,
            heuristic: heuristic,
            preset: preset
        )
        path.wrappedValue.removeLast()
    }

    func editConfiguration() {
        // TODO: #397, edit configuration as text
    }
}

// MARK: - Destinations

private extension WireGuardView {
    enum Subroute: Hashable {
        case providerServer

        case providerKey
    }

    @ViewBuilder
    func destination(for route: Subroute) -> some View {
        switch route {
        case .providerServer:
            draft.module.providerSelection.map {
                ProviderServerView(
                    moduleId: draft.module.id,
                    providerId: $0.id,
                    selectedEntity: $0.entity,
                    filtersWithSelection: true,
                    onSelect: onSelectServer
                )
            }

        case .providerKey:
            // TODO: #339, WireGuard upload public key to provider
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview {
    let module = WireGuardModule.Builder(configurationBuilder: .forPreviews)
    return module.preview()
}
