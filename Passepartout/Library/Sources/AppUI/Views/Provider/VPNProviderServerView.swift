//
//  VPNProviderServerView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/7/24.
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

import AppLibrary
import PassepartoutKit
import SwiftUI

struct VPNProviderServerView<Configuration>: View where Configuration: ProviderConfigurationIdentifiable & Codable {

    @Environment(\.dismiss)
    private var dismiss

    @ObservedObject
    var manager: VPNProviderManager

    let onSelect: (_ server: VPNServer, _ preset: VPNPreset<Configuration>) -> Void

    var body: some View {
        serversView
            .modifier(VPNFiltersModifier<Configuration>(manager: manager))
            .navigationTitle(Strings.Global.servers)
    }
}

// MARK: - Actions

extension VPNProviderServerView {
    func selectServer(_ server: VPNServer) {
        guard let preset = compatiblePreset(with: server) else {
            // FIXME: #703, alert select a preset
            return
        }
        onSelect(server, preset)
        dismiss()
    }
}

private extension VPNProviderServerView {
    func compatiblePreset(with server: VPNServer) -> VPNPreset<Configuration>? {
        manager
            .presets(ofType: Configuration.self)
            .first {
                if let supportedIds = server.provider.supportedPresetIds {
                    return supportedIds.contains($0.presetId)
                }
                return true
            }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VPNProviderServerView<OpenVPN.Configuration>(manager: VPNProviderManager()) { _, _ in
        }
    }
    .withMockEnvironment()
}
