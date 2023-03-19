//
//  EndpointView+OpenVPN.swift
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
import TunnelKitOpenVPN

extension EndpointView {
    struct OpenVPNView: View {
        @Environment(\.presentationMode) private var presentationMode

        @ObservedObject private var providerManager: ProviderManager

        @ObservedObject private var currentProfile: ObservableProfile

        @Binding private var builder: OpenVPN.ConfigurationBuilder

        @Binding private var customEndpoint: Endpoint?

        private var isConfigurationReadonly: Bool {
            currentProfile.value.isProvider
        }

        @State private var isFirstAppearance = true

        @State private var isAutomatic = false

        @State private var selectedSocketType: SocketType = .udp

        @State private var selectedPort: UInt16 = 0

        // XXX: do not escape mutating 'self', use constant providerManager
        init(currentProfile: ObservableProfile) {
            let providerManager: ProviderManager = .shared

            self.providerManager = providerManager
            self.currentProfile = currentProfile

            _builder = .init {
                if currentProfile.value.isProvider {
                    guard let server = currentProfile.value.providerServer(providerManager) else {
                        assertionFailure("Server not found")
                        return .init()
                    }
                    guard let preset = currentProfile.value.providerPreset(server) else {
                        assertionFailure("Preset not found")
                        return .init()
                    }
                    guard let cfg = preset.openVPNConfiguration else {
                        assertionFailure("Preset \(preset.id) (\(preset.name)) has no OpenVPN configuration")
                        return .init()
                    }
                    var builder = cfg.builder(withFallbacks: true)
                    try? builder.setRemotes(from: preset, with: server, excludingHostname: false)
                    return builder
                } else if let cfg = currentProfile.value.hostOpenVPNSettings?.configuration {
                    let builder = cfg.builder(withFallbacks: true)
//                    pp_log.debug("Loading OpenVPN configuration: \(builder)")
                    return builder
                }
                // fall back gracefully
                return .init()
            } set: {
                if currentProfile.value.isProvider {
                    // readonly
                } else {
                    pp_log.debug("Saving OpenVPN configuration: \($0)")
                    currentProfile.value.hostOpenVPNSettings?.configuration = $0.build()
                }
            }
            _customEndpoint = .init {
                if currentProfile.value.isProvider {
                    return currentProfile.value.providerCustomEndpoint
                } else {
                    return currentProfile.value.hostOpenVPNSettings?.customEndpoint
                }
            } set: {
                if currentProfile.value.isProvider {
                    currentProfile.value.providerCustomEndpoint = $0
                } else {
                    currentProfile.value.hostOpenVPNSettings?.customEndpoint = $0
                }
            }
        }

        var body: some View {
            ScrollViewReader { scrollProxy in
                List {
                    mainSection
                    if !isAutomatic {
                        filtersSection
                        addressesSection
                    }
                    advancedSection
                }.onAppear {
                    scrollToCustomEndpoint(scrollProxy)
                    preselectFilters(once: true)
                }.onChange(of: isAutomatic, perform: onToggleAutomatic)
                .onChange(of: selectedSocketType, perform: preselectPort)
                .onChange(of: customEndpoint) { _ in
                    withAnimation {
                        preselectFilters(once: false)
                    }
                }
            }.navigationTitle(L10n.Global.Strings.endpoint)
        }
    }
}

extension EndpointView.OpenVPNView {
    private var mainSection: some View {
        Section {
            Toggle(L10n.Global.Strings.automatic, isOn: $isAutomatic.themeAnimation())
        }
    }

    private var filtersSection: some View {
        Section {
            themeTextPicker(
                L10n.Global.Strings.protocol,
                selection: $selectedSocketType,
                values: availableSocketTypes,
                description: \.rawValue
            )
            themeTextPicker(
                L10n.Global.Strings.port,
                selection: $selectedPort,
                values: allPorts(forSocketType: selectedSocketType),
                description: \.description
            )
        }
    }

    private var addressesSection: some View {
        Section {
            filteredRemotes.map {
                ForEach($0, content: button(forEndpoint:))
            }
        } header: {
            Text(L10n.Global.Strings.addresses)
        }
    }

    private var advancedSection: some View {
        Section {
            let caption = L10n.Endpoint.Advanced.title
            NavigationLink(caption) {
                EndpointAdvancedView.OpenVPNView(
                    builder: $builder,
                    isReadonly: isConfigurationReadonly,
                    isServerPushed: false
                ).navigationTitle(caption)
            }
        }
    }

    private func button(forEndpoint endpoint: Endpoint?) -> some View {
        Button {
            customEndpoint = endpoint
            presentationMode.wrappedValue.dismiss()
        } label: {
            text(forEndpoint: endpoint)
        }.withTrailingCheckmark(when: customEndpoint == endpoint)
    }

    private func text(forEndpoint endpoint: Endpoint?) -> some View {
        Text(endpoint?.address ?? L10n.Global.Strings.automatic)
            .themeLongTextStyle()
    }
}

extension EndpointView.OpenVPNView {
    private func onToggleAutomatic(_ value: Bool) {
        if value {
            guard customEndpoint != nil else {
                return
            }
            customEndpoint = nil
        }
    }

    private func preselectFilters(once: Bool) {
        guard !once || isFirstAppearance else {
            return
        }
        isFirstAppearance = false

        if let customEndpoint = customEndpoint {
            isAutomatic = false
            selectedSocketType = customEndpoint.proto.socketType
            selectedPort = customEndpoint.proto.port
        } else {
            isAutomatic = true
            guard let socketType = availableSocketTypes.first else {
                assertionFailure("No socket types, empty remotes?")
                return
            }
            selectedSocketType = socketType
            preselectPort(forSocketType: socketType)
        }
    }

    private func preselectPort(forSocketType socketType: SocketType) {
        let supported = allPorts(forSocketType: socketType)
        guard !supported.contains(selectedPort) else {
            return
        }
        guard let port = supported.first else {
            assertionFailure("No ports, empty remotes?")
            return
        }
        selectedPort = port
    }

    private var availableSocketTypes: [SocketType] {
        guard let remotes = builder.remotes else {
            return []
        }
        let allTypes: [SocketType] = [
            SocketType.udp,
            SocketType.tcp,
            SocketType.udp4,
            SocketType.tcp4
        ]
        var availableTypes: [SocketType] = []
        allTypes.forEach { socketType in
            guard remotes.contains(where: {
                $0.proto.socketType == socketType
            }) else {
                return
            }
            availableTypes.append(socketType)
        }
        return availableTypes
    }

    private func allPorts(forSocketType socketType: SocketType) -> [UInt16] {
        guard let remotes = builder.remotes else {
            return []
        }
        let allPorts = Set(remotes.filter {
            $0.proto.socketType == socketType
        }.map(\.proto.port))
        return Array(allPorts).sorted()
    }

    private var filteredRemotes: [Endpoint]? {
        builder.remotes?.filter {
            $0.proto.socketType == selectedSocketType && $0.proto.port == selectedPort
        }
    }
}

extension EndpointView.OpenVPNView {
    private func scrollToCustomEndpoint(_ proxy: ScrollViewProxy) {
        proxy.maybeScrollTo(customEndpoint?.id)
    }
}
