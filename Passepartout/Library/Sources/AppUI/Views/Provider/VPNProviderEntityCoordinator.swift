//
//  VPNProviderEntityCoordinator.swift
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

import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct VPNProviderEntityCoordinator<Configuration>: View where Configuration: ProviderConfigurationIdentifiable & Codable {

    @Environment(\.dismiss)
    private var dismiss

    let providerId: ProviderID

    let selectedEntity: VPNEntity<Configuration>?

    let onSelect: (VPNEntity<Configuration>) async throws -> Void

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        NavigationStack {
            VPNProviderServerView(
                apis: API.shared,
                providerId: providerId,
                configurationType: Configuration.self,
                selectedEntity: selectedEntity,
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

private extension VPNProviderEntityCoordinator {
    func onSelect(server: VPNServer, preset: VPNPreset<Configuration>) {
        Task {
            let entity = VPNEntity(server: server, preset: preset)
            do {
                try await onSelect(entity)
                dismiss()
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}
