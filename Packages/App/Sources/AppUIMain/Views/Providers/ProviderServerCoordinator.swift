//
//  ProviderServerCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/16/24.
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

struct ProviderServerCoordinator: View {

    @Environment(\.dismiss)
    private var dismiss

    let providerId: ProviderID

    let moduleType: ModuleType

    let selectedEntity: ProviderEntity?

    let selectTitle: String

    let onSelect: (ProviderEntity) async throws -> Void

    @ObservedObject
    var errorHandler: ErrorHandler

    var body: some View {
        ProviderServerView(
            providerId: providerId,
            moduleType: moduleType,
            selectedEntity: selectedEntity,
            selectTitle: selectTitle,
            onSelect: onSelect
        )
        .themeNavigationStack(closable: true)
    }
}

private extension ProviderServerCoordinator {
    func onSelect(entity: ProviderEntity) {
        Task {
            do {
                dismiss()
                try await onSelect(entity)
            } catch {
                pp_log(.app, .fault, "Unable to select server \(entity.server.serverId) for provider \(entity.server.metadata.providerId): \(error)")
                errorHandler.handle(error, title: Strings.Views.Providers.selectEntity)
            }
        }
    }
}
