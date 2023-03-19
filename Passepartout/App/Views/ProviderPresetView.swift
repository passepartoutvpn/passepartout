//
//  ProviderPresetView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import SwiftUI
import PassepartoutLibrary

struct ProviderPresetView: View {
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject private var providerManager: ProviderManager

    @ObservedObject private var currentProfile: ObservableProfile

    private var server: ProviderServer?

    @Binding private var selectedPreset: ProviderServer.Preset?

    // XXX: do not escape mutating 'self', use constant providerManager
    init(currentProfile: ObservableProfile) {
        let providerManager: ProviderManager = .shared

        self.providerManager = providerManager
        self.currentProfile = currentProfile

        server = currentProfile.value.providerServer(providerManager)
        _selectedPreset = .init {
            guard let serverId = currentProfile.value.providerServerId else {
                return nil
            }
            guard let server = providerManager.server(withId: serverId) else {
                return nil
            }
            return currentProfile.value.providerPreset(server)
        } set: {
            // user never selects a nil preset
            guard let preset = $0 else {
                return
            }
            currentProfile.value.setProviderPreset(preset)
        }
    }

    var body: some View {
        List {
            ForEach(availablePresets, id: \.id, content: presetSection)
        }.navigationTitle(L10n.Provider.Preset.title)
    }

    private func presetSection(_ preset: ProviderServer.Preset) -> some View {
        Section {
            Button {
                selectedPreset = preset
                presentationMode.wrappedValue.dismiss()
            } label: {
                presetSelectionRow(preset)
            }
            NavigationLink(L10n.Endpoint.Advanced.title) {

                // TODO: WireGuard, preset assumes OpenVPN (read current protocol instead)
                preset.openVPNConfiguration.map {
                    EndpointAdvancedView.OpenVPNView(
                        builder: .constant($0.builder()),
                        isReadonly: true,
                        isServerPushed: false
                    ).navigationTitle(preset.name)
                }
            }
        } header: {
            Text(preset.name)
        }
    }

    private func presetSelectionRow(_ preset: ProviderServer.Preset) -> some View {
        Text(preset.comment)
            .withTrailingCheckmark(when: preset.id == selectedPreset?.id)
    }

    // some providers (e.g. NordVPN) have specific presets based on selected server
    private var availablePresets: [ProviderServer.Preset] {
        server?.presets?.sorted() ?? []
    }
}
