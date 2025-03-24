//
//  ProviderView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/15/25.
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
import PassepartoutKit
import SwiftUI

struct ProviderView: View, ModuleDraftEditing {

    @EnvironmentObject
    private var apiManager: APIManager

    @EnvironmentObject
    private var preferencesManager: PreferencesManager

    @ObservedObject
    var draft: ModuleDraft<ProviderModule.Builder>

    private let registry: Registry

    @StateObject
    private var providerPreferences = ProviderPreferences()

    @State
    private var availablePresets: [ProviderPreset] = []

    @State
    private var paywallReason: PaywallReason?

    init(draft: ModuleDraft<ProviderModule.Builder>, parameters: ModuleViewParameters) {
        self.draft = draft
        registry = parameters.registry
    }

    var body: some View {
        debugChanges()
        return contentView
            .moduleView(draft: draft)
            .modifier(PaywallModifier(reason: $paywallReason))
            .onLoad(perform: loadCurrentProvider)
            .onChange(of: providerId) { newId in
                Task {
                    if let newId {
                        await refreshInfrastructure(for: newId)
                    }
                    loadPreferences(for: newId)
                }
            }
            .onChange(of: providerEntity) { entity in
                guard let entity else {
                    return
                }
                Task {
                    await loadSupportedPresets(for: entity.server)
                }
            }
            .onDisappear(perform: savePreferences)
            .disabled(apiManager.isLoading)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.draft.module.providerId == rhs.draft.module.providerId
    }
}

// MARK: - Content

private extension ProviderView {

    @ViewBuilder
    var contentView: some View {
        providerSection
        if providerType != nil {
            targetSection
        }
        if providerId != nil {
            optionsSection
        }
    }

    var providerSection: some View {
        Group {
            providerPicker
            moduleTypePicker
        }
        .themeSection()
    }

#if os(iOS)
    var targetSection: some View {
        Group {
            serverLink
            presetPicker
            if let providerId {
                RefreshInfrastructureButton(providerId: providerId)
            }
        }
        .themeSection(footer: lastUpdatedString)
    }
#else
    var targetSection: some View {
        Group {
            serverLink
            presetPicker
            if let providerId {
                HStack {
                    lastUpdatedString.map {
                        Text($0)
                            .themeSubtitle()
                    }
                    Spacer()
                    RefreshInfrastructureButton(providerId: providerId)
                }
            }
        }
        .themeSection()
    }
#endif

    var providerPicker: some View {
        ProviderPicker(
            providers: supportedProviders,
            providerId: $draft.module.providerId,
            isLoading: apiManager.isLoading,
            paywallReason: $paywallReason
        )
    }

    var moduleTypePicker: some View {
        Picker(Strings.Views.Providers.module, selection: $draft.module.providerModuleType) {
            Text(Strings.Views.Providers.selectModule)
                .tag(nil as ModuleType?)
            ForEach(supportedTypes, id: \.rawValue) {
                Text($0.localizedDescription)
                    .tag($0 as ModuleType?)
            }
        }
    }

    var serverLink: some View {
        ProviderServerLink(entity: providerEntity)
    }

    var presetPicker: some View {
        Picker(Strings.Views.Providers.preset, selection: presetIdBinding) {
            if draft.module.entity == nil {
                Text(Strings.Views.Providers.Preset.placeholder)
                    .tag(nil as String?)
            }
            ForEach(availablePresets, id: \.presetId) {
                Text($0.description)
                    .tag($0.presetId as String?)
            }
        }
        .disabled(draft.module.entity == nil)
    }

    var optionsSection: some View {
        Group {
            switch providerType {
            case .openVPN:
                OpenVPNCredentialsLink()
                resolvedModuleLink
            case .wireGuard:
                // TODO: ###, WireGuard provider private key
                EmptyView()
            default:
                EmptyView()
            }
        }
        .themeSection(header: optionsHeader)
    }

    var optionsHeader: String? {
        guard let providerType else {
            return nil
        }
        switch providerType {
        case .openVPN:
            return providerType.localizedDescription
        default:
            return nil
        }
    }

    var resolvedModuleLink: some View {
        resolvedModule.map { module in
            NavigationLink(Strings.Global.Nouns.configuration) {
                if let ovpn = module as? OpenVPNModule,
                   let configuration = ovpn.configuration?.builder() {
                    OpenVPNConfigurationView(configuration: configuration)
                }
            }
        }
    }
}

private extension ProviderView {
    var providerId: ProviderID? {
        draft.module.providerId
    }

    var provider: Provider? {
        providerId.map {
            apiManager.provider(withId: $0)
        } ?? nil
    }

    var providerType: ModuleType? {
        draft.module.providerModuleType
    }

    var providerEntity: ProviderEntity? {
        draft.module.entity
    }

    var supportedProviders: [Provider] {
        apiManager.providers
    }

    var supportedTypes: [ModuleType] {
        provider?.metadata.keys.sorted() ?? []
    }

    var presetIdBinding: Binding<String?> {
        Binding {
            draft.module.entity?.preset.presetId
        } set: {
            guard let entity = draft.module.entity,
                  let presetId = $0,
                  let preset = availablePresets.first(where: { $0.presetId == presetId }) else {
                return
            }
            draft.module.entity = ProviderEntity(
                server: entity.server,
                preset: preset,
                heuristic: entity.heuristic
            )
        }
    }

    var resolvedModule: Module? {
        do {
            let module = try draft.module.tryBuild()
            return try module.resolvedModule(with: registry)
        } catch {
            pp_log(.app, .error, "Unable to resolve provider module: \(error)")
            return nil
        }
    }

    var lastUpdate: Date? {
        guard let providerId else {
            return nil
        }
        return apiManager.lastUpdate(for: providerId)
    }

    var lastUpdatedString: String? {
        guard let lastUpdate else {
            return apiManager.isLoading ? Strings.Views.Providers.LastUpdated.loading : nil
        }
        return Strings.Views.Providers.lastUpdated(lastUpdate.localizedDescription(style: .timestamp))
    }

    func loadCurrentProvider() {
       Task {
           await refreshIndex()
           if let providerId {
               loadPreferences(for: providerId)
               if let providerEntity {
                   await loadSupportedPresets(for: providerEntity.server)
               }
           }
       }
    }

    func refreshIndex() async {
        do {
            try await apiManager.fetchIndex()
        } catch {
            pp_log(.app, .error, "Unable to fetch index: \(error)")
        }
    }

    func refreshInfrastructure(for newProviderId: ProviderID) async {
        do {
            try await apiManager.fetchInfrastructure(for: newProviderId)
        } catch {
            pp_log(.app, .error, "Unable to refresh infrastructure: \(error)")
        }
    }

    func loadSupportedPresets(for server: ProviderServer) async {
        guard let providerType else {
            return
        }
        do {
            availablePresets = try await apiManager.presets(for: server, moduleType: providerType)
        } catch {
            pp_log(.app, .error, "Unable to fetch presets for current server: \(error)")
            availablePresets = []
        }
    }

    func loadPreferences(for newProviderId: ProviderID?) {
        if let newProviderId {
            do {
                pp_log(.app, .debug, "Load preferences for provider \(newProviderId)")
                let repository = try preferencesManager.preferencesRepository(forProviderWithId: newProviderId)
                providerPreferences.setRepository(repository)
            } catch {
                pp_log(.app, .error, "Unable to load preferences for provider \(newProviderId): \(error)")
                providerPreferences.setRepository(nil)
            }
        } else {
            providerPreferences.setRepository(nil)
        }
    }

    func savePreferences() {
        do {
            pp_log(.app, .debug, "Save preferences for provider \(providerId.debugDescription)")
            try providerPreferences.save()
        } catch {
            pp_log(.app, .error, "Unable to save preferences for provider \(providerId.debugDescription): \(error)")
        }
    }
}

// MARK: - Previews

#Preview {
    var module = ProviderModule.Builder()
    module.providerId = .hideme
    return module.preview()
}
