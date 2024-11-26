//
//  VPNProviderServerCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/16/24.
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

import CommonUtils
import PassepartoutKit
import SwiftUI

struct VPNProviderServerCoordinator<Configuration>: View where Configuration: ProviderConfigurationIdentifiable & Codable {

    @Environment(\.dismiss)
    private var dismiss

    let moduleId: UUID

    let providerId: ProviderID

    let selectedEntity: VPNEntity<Configuration>?

    let onSelect: (VPNEntity<Configuration>) async throws -> Void

    @ObservedObject
    var errorHandler: ErrorHandler

    var body: some View {
        VPNProviderServerView(
            moduleId: moduleId,
            providerId: providerId,
            configurationType: Configuration.self,
            selectedEntity: selectedEntity,
            filtersWithSelection: false,
            selectTitle: Strings.Global.Actions.connect,
            onSelect: onSelect
        )
        .themeNavigationStack(closable: true)
    }
}

private extension VPNProviderServerCoordinator {
    func onSelect(server: VPNServer, preset: VPNPreset<Configuration>) {
        Task {
            do {
                let entity = VPNEntity(server: server, preset: preset)
                dismiss()
                try await onSelect(entity)
            } catch {
                pp_log(.app, .fault, "Unable to select server \(server.serverId) for provider \(server.provider.id): \(error)")
                errorHandler.handle(error, title: Strings.Views.Providers.selectEntity)
            }
        }
    }
}
