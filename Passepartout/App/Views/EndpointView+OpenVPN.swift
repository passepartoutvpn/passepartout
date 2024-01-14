//
//  EndpointView+OpenVPN.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
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

#if !os(tvOS)
import PassepartoutLibrary
import SwiftUI
import TunnelKitOpenVPN

extension EndpointView {
    struct OpenVPNView: View {
        @ObservedObject private var providerManager: ProviderManager

        @ObservedObject private var currentProfile: ObservableProfile

        @Binding private var builder: OpenVPN.ConfigurationBuilder

        @State private var isFirstAppearance = true

        @State private var isAutomatic = false

        @State private var isExpanded: [String: Bool] = [:]

        @State private var isAdding = false

        @State private var editedEndpoint: Endpoint?

        init(currentProfile: ObservableProfile) {
            let providerManager: ProviderManager = .shared

            self.providerManager = providerManager
            self.currentProfile = currentProfile

            _builder = currentProfile.builderBinding(providerManager: providerManager)
        }

        var body: some View {
            ScrollViewReader { scrollProxy in
                List {
                    mainSection
                    if isConfigurationReadonly {
                        groupedEndpointsSections
                    } else {
                        endpointsSection
                    }
                    advancedSection
                }.onAppear {
                    isAutomatic = (currentProfile.value.customEndpoint == nil)
                    if let customEndpoint = currentProfile.value.customEndpoint {
                        isExpanded[customEndpoint.address] = true
                    }
                    scrollToCustomEndpoint(scrollProxy)
                }.onChange(of: isAutomatic, perform: onToggleAutomatic)
                .toolbar {
                    if !isConfigurationReadonly {
                        addButton
                    }
                }
            }.navigationTitle(L10n.Global.Strings.endpoint)
        }
    }
}

// MARK: -

private extension EndpointView.OpenVPNView {
    var isConfigurationReadonly: Bool {
        currentProfile.value.isProvider
    }

    var mainSection: some View {
        Section {
            Toggle(L10n.Global.Strings.automatic, isOn: $isAutomatic.themeAnimation())
        } footer: {
            themeErrorMessage(isManualEndpointRequired ? L10n.Endpoint.Errors.endpointRequired : nil)
        }
    }

    var advancedSection: some View {
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

    var isManualEndpointRequired: Bool {
        !isAutomatic && currentProfile.value.customEndpoint == nil
    }
}

// MARK: -

private extension EndpointView.OpenVPNView {
    func onToggleAutomatic(_ value: Bool) {
        guard value else {
            return
        }
        guard currentProfile.value.customEndpoint != nil else {
            return
        }
        withAnimation {
            currentProfile.value.customEndpoint = nil
            isExpanded.removeAll()
        }
    }

    func scrollToCustomEndpoint(_ proxy: ScrollViewProxy) {
        proxy.maybeScrollTo(currentProfile.value.customEndpoint?.id)
    }
}

// MARK: - Editable: linear

private extension EndpointView.OpenVPNView {
    var endpointsSection: some View {
        Section {
            ForEach(builder.remotes ?? []) { endpoint in
                rowForEndpoint(endpoint)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        actions(forEndpoint: endpoint)
                    }
            }.onMove(perform: moveEndpoints)
                .disabled(isAutomatic)
        }
    }

    func rowForEndpoint(_ endpoint: Endpoint) -> some View {
        Button {
            withAnimation {
                currentProfile.value.customEndpoint = endpoint
            }
        } label: {
            labelForEndpoint(endpoint)
        }.sheet(item: $editedEndpoint) { endpoint in
            NavigationView {
                EndpointView.AddView(L10n.Global.Strings.edit, endpoint: endpoint, onSave: commitEndpoint)
            }.themeGlobal()
        }.withTrailingCheckmark(when: currentProfile.value.customEndpoint == endpoint)
    }

    func labelForEndpoint(_ endpoint: Endpoint) -> some View {
        VStack {
            Text(endpoint.address)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(endpoint.proto.rawValue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    func actions(forEndpoint endpoint: Endpoint) -> some View {
        if !isConfigurationReadonly {
            if (builder.remotes?.count ?? 0) > 1 {
                removeButton(forEndpoint: endpoint)
            }
            editButton(forEndpoint: endpoint)
        }
    }

    var addButton: some View {
        Button {
            isAdding = true
        } label: {
            themeAddMenuImage.asSystemImage
        }.sheet(isPresented: $isAdding) {
            NavigationView {
                EndpointView.AddView(L10n.Global.Strings.add, onSave: commitEndpoint)
            }.themeGlobal()
        }
    }

    func removeButton(forEndpoint endpoint: Endpoint) -> some View {
        Button(role: .destructive) {
            deleteEndpoint(endpoint)
        } label: {
            Text(L10n.Global.Strings.delete)
        }.themeDestructiveTintStyle()
    }

    func editButton(forEndpoint endpoint: Endpoint) -> some View {
        Button {
            editedEndpoint = endpoint
        } label: {
            Text(L10n.Global.Strings.edit)
        }.themePrimaryTintStyle()
    }
}

private extension EndpointView.OpenVPNView {
    func commitEndpoint(_ newEndpoint: Endpoint, editedEndpoint: Endpoint?) {
        withAnimation {

            // replace existing
            if let editedEndpoint,
               let editedIndex = builder.remotes?.firstIndex(where: { $0 == editedEndpoint }) {

                builder.remotes?[editedIndex] = newEndpoint
                if currentProfile.value.customEndpoint == editedEndpoint {
                    currentProfile.value.customEndpoint = newEndpoint
                }
            }
            // add new
            else {
                if builder.remotes != nil {
                    builder.remotes?.append(newEndpoint)
                } else {
                    assertionFailure("Nil remotes, how did we get here?")
                    builder.remotes = [newEndpoint]
                }
            }
        }
    }

    func moveEndpoints(fromOffsets: IndexSet, toOffset: Int) {
        builder.remotes?.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func deleteEndpoint(_ endpoint: Endpoint) {
        withAnimation {
            builder.remotes?.removeAll {
                $0 == endpoint
            }
            if currentProfile.value.customEndpoint == endpoint {
                currentProfile.value.customEndpoint = nil
            }
        }
    }
}

// MARK: - Non-editable: group by address

private extension EndpointView.OpenVPNView {
    var groupedEndpointsSections: some View {
        ForEach(endpointsByAddress, content: group(forEndpointsSection:))
            .disabled(isAutomatic)
    }

    func group(forEndpointsSection section: EndpointsByAddress) -> some View {
        Section {
            DisclosureGroup(isExpanded: isExpandedBinding(address: section.address)) {
                ForEach(section.endpoints, content: rowForEndpointProtocol)
            } label: {
                labelForEndpointAddress(section.address)
            }
        }
    }

    func labelForEndpointAddress(_ address: String) -> some View {
        Text(address)
    }

    func rowForEndpointProtocol(_ endpoint: Endpoint) -> some View {
        Button {
            withAnimation {
                currentProfile.value.customEndpoint = endpoint
            }
        } label: {
            labelForEndpointProtocol(endpoint.proto)
        }.withTrailingCheckmark(when: currentProfile.value.customEndpoint == endpoint)
    }

    func labelForEndpointProtocol(_ proto: EndpointProtocol) -> some View {
        Text(proto.rawValue)
    }

    var endpointsByAddress: [EndpointsByAddress] {
        guard let remotes = builder.remotes, !remotes.isEmpty else {
            return []
        }
        var uniqueAddresses: [String] = []
        remotes.forEach {
            guard !uniqueAddresses.contains($0.address) else {
                return
            }
            uniqueAddresses.append($0.address)
        }
        return uniqueAddresses.map {
            EndpointsByAddress(address: $0, remotes: remotes)
        }
    }
}

private struct EndpointsByAddress: Identifiable {
    let address: String

    let endpoints: [Endpoint]

    init(address: String, remotes: [Endpoint]?) {
        self.address = address
        endpoints = remotes?.filter {
            $0.address == address
        }.sorted() ?? []
    }

    // MARK: Identifiable

    var id: String {
        address
    }
}

// MARK: - Bindings

private extension ObservableProfile {

    @MainActor
    func builderBinding(providerManager: ProviderManager) -> Binding<OpenVPN.ConfigurationBuilder> {
        .init {
            if self.value.isProvider {
                guard let server = self.value.providerServer(providerManager) else {
                    assertionFailure("Server not found")
                    return .init()
                }
                guard let preset = self.value.providerPreset(server) else {
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
            } else if let cfg = self.value.hostOpenVPNSettings?.configuration {
                let builder = cfg.builder(withFallbacks: true)
//                pp_log.debug("Loading OpenVPN configuration: \(builder)")
                return builder
            }
            // fall back gracefully
            return .init()
        } set: {
            if self.value.isProvider {
                // readonly
            } else {
                pp_log.verbose("Saving OpenVPN configuration: \($0)")
                self.value.hostOpenVPNSettings?.configuration = $0.build()
            }
        }
    }
}

private extension EndpointView.OpenVPNView {
    func isExpandedBinding(address: String) -> Binding<Bool> {
        .init {
            isExpanded[address] ?? false
        } set: {
            isExpanded[address] = $0
        }
    }
}

private extension Profile {
    var customEndpoint: Endpoint? {
        get {
            if isProvider {
                return providerCustomEndpoint
            } else {
                return hostOpenVPNSettings?.customEndpoint
            }
        }
        set {
            if isProvider {
                providerCustomEndpoint = newValue
            } else {
                hostOpenVPNSettings?.customEndpoint = newValue
            }
        }
    }
}
#endif
