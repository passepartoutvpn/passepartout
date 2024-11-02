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

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        NavigationStack {
            VPNProviderServerView(
                moduleId: moduleId,
                providerId: providerId,
                configurationType: Configuration.self,
                selectedEntity: selectedEntity,
                filtersWithSelection: false,
                selectTitle: Strings.Global.connect,
                onSelect: onSelect
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
#if os(iOS)
                        ThemeImage(.close)
#else
                        Text(Strings.Global.cancel)
#endif
                    }
                }
            }
            .withErrorHandler(errorHandler)
        }
    }
}

private extension VPNProviderServerCoordinator {
    func onSelect(server: VPNServer, preset: VPNPreset<Configuration>) {
        Task {
            do {
                let entity = VPNEntity(server: server, preset: preset)
                try await onSelect(entity)
                dismiss()
            } catch {
                pp_log(.app, .fault, "Unable to select server \(server.serverId) for provider \(server.provider.id): \(error)")
                errorHandler.handle(error, title: Strings.Global.servers)
            }
        }
    }
}
