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
    private var configurationViewModel = ConfigurationView.ViewModel()

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
                errorHandler: errorHandler,
                onImport: {
                    guard let configurationBuilder = $0 else {
                        return
                    }
                    configurationViewModel.load(from: configurationBuilder)
                }
            ))
            .modifier(PaywallModifier(reason: $paywallReason))
            .withErrorHandler(errorHandler)
    }
}

// MARK: - Content

private extension WireGuardView {

    @ViewBuilder
    var contentView: some View {
        if draft.module.configurationBuilder != nil {
            ModuleImportSection(isImporting: $isImporting)
            ConfigurationView(
                draft: draft,
                viewModel: $configurationViewModel,
                keyGenerator: impl?.keyGenerator
            )
            .onLoad {
                guard let configurationBuilder = draft.module.configurationBuilder else {
                    return
                }
                configurationViewModel.load(from: configurationBuilder)
            }
        } else {
            ModuleImportSection(isImporting: $isImporting)
        }
    }
}

private extension WireGuardView {
    func editConfiguration() {
        // TODO: #397, edit configuration as text
    }
}

// MARK: - Previews

#Preview {
    let module = WireGuardModule.Builder(configurationBuilder: .forPreviews)
    return module.preview()
}
