//
//  APIContentModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/14/24.
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

import CommonAPI
import CommonLibrary
import PassepartoutKit
import SwiftUI
import UILibrary

struct APIContentModifier<Template, ProviderRows>: ViewModifier where Template: IdentifiableConfiguration, ProviderRows: View {

    @EnvironmentObject
    private var apiManager: APIManager

    @EnvironmentObject
    private var preferencesManager: PreferencesManager

    @Binding
    var providerId: ProviderID?

    let providerPreferences: ProviderPreferences?

    let templateType: Template.Type

    @Binding
    var paywallReason: PaywallReason?

    @ViewBuilder
    let providerRows: ProviderRows

    let onSelectProvider: (APIManager, ProviderID?, _ isInitial: Bool) -> Void

    func body(content: Content) -> some View {
        providerView
            .onLoad(perform: loadCurrentProvider)
            .onChange(of: providerId) { newId in
                Task {
                    if let newId {
                        await refreshInfrastructure(for: newId)
                    }
                    loadPreferences(for: newId)
                    onSelectProvider(apiManager, newId, false)
                }
            }
            .onDisappear(perform: savePreferences)
            .disabled(apiManager.isLoading)

        content
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.providerId == rhs.providerId
    }
}

private extension APIContentModifier {

#if os(iOS)
    @ViewBuilder
    var providerView: some View {
        providerPicker
            .themeSection()

        if let providerId {
            Group {
                providerRows
                RefreshInfrastructureButton(providerId: providerId)
            }
            .themeSection(footer: lastUpdatedString)
        }
    }
#else
    @ViewBuilder
    var providerView: some View {
        Section {
            providerPicker
        }
        if let providerId {
            Section {
                providerRows
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
    }
#endif

    var providerPicker: some View {
        ProviderPicker(
            providers: supportedProviders,
            providerId: $providerId,
            isRequired: true,
            isLoading: apiManager.isLoading,
            paywallReason: $paywallReason
        )
    }
}

private extension APIContentModifier {
    var supportedProviders: [Provider] {
        apiManager
            .providers
            .filter {
                $0.supports(Template.self)
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
               onSelectProvider(apiManager, providerId, true)
               loadPreferences(for: providerId)
           }
       }
    }

    @discardableResult
    func refreshIndex() async -> Bool {
        do {
            try await apiManager.fetchIndex()
            return true
        } catch {
            pp_log(.app, .error, "Unable to fetch index: \(error)")
            return false
        }
    }

    @discardableResult
    func refreshInfrastructure(for providerId: ProviderID) async -> Bool {
        do {
            try await apiManager.fetchInfrastructure(for: providerId)
            return true
        } catch {
            pp_log(.app, .error, "Unable to refresh infrastructure: \(error)")
            return false
        }
    }

    func loadPreferences(for providerId: ProviderID?) {
        guard let providerPreferences else {
            return
        }
        if let providerId {
            do {
                pp_log(.app, .debug, "Load preferences for provider \(providerId)")
                let repository = try preferencesManager.preferencesRepository(forProviderWithId: providerId)
                providerPreferences.setRepository(repository)
            } catch {
                pp_log(.app, .error, "Unable to load preferences for provider \(providerId): \(error)")
                providerPreferences.setRepository(nil)
            }
        } else {
            providerPreferences.setRepository(nil)
        }
    }

    func savePreferences() {
        guard let providerPreferences else {
            return
        }
        do {
            pp_log(.app, .debug, "Save preferences for provider \(providerId.debugDescription)")
            try providerPreferences.save()
        } catch {
            pp_log(.app, .error, "Unable to save preferences for provider \(providerId.debugDescription): \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        EmptyView()
            .modifier(APIContentModifier(
                providerId: .constant(.hideme),
                providerPreferences: nil,
                templateType: OpenVPNProviderTemplate.self,
                paywallReason: .constant(nil),
                providerRows: {},
                onSelectProvider: { _, _, _ in }
            ))
    }
    .withMockEnvironment()
}
