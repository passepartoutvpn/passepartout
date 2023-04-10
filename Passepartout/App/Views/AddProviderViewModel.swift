//
//  AddProviderViewModel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/19/22.
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

import Foundation
import PassepartoutLibrary

extension AddProviderView {
    class ViewModel: ObservableObject {
        enum PendingOperation {
            case index

            case provider(ProviderName)
        }

        var isUpdatingIndex: Bool {
            if case .index = pendingOperation {
                return true
            }
            return false
        }

        var isFetchingAnyProvider: Bool {
            if case .provider = pendingOperation {
                return true
            }
            return false
        }

        func isFetchingProvider(_ name: ProviderName) -> Bool {
            if case .provider(name) = pendingOperation {
                return true
            }
            return false
        }

        @Published var selectedVPNProtocol: VPNProtocolType = .openVPN

        @Published var selectedProvider: ProviderMetadata?

        @Published var pendingProfile: Profile = .placeholder

        @Published private(set) var pendingOperation: PendingOperation?

        @Published var isPaywallPresented = false

        @Published private(set) var errorMessage: String?

        func selectProvider(_ metadata: ProviderMetadata, _ providerManager: ProviderManager) {
            errorMessage = nil
            guard let server = providerManager.anyDefaultServer(
                metadata.name,
                vpnProtocol: selectedVPNProtocol
            ) else {
                selectProviderAfterFetchingInfrastructure(metadata, providerManager)
                return
            }
            doSelectProvider(metadata, server)
        }

        private func selectProviderAfterFetchingInfrastructure(_ metadata: ProviderMetadata, _ providerManager: ProviderManager) {
            errorMessage = nil
            pendingOperation = .provider(metadata.name)
            Task { @MainActor in
                do {
                    try await providerManager.fetchProviderPublisher(
                        withName: metadata.name,
                        vpnProtocol: pendingProfile.currentVPNProtocol,
                        priority: .remoteThenBundle
                    ).async()

                    if let server = providerManager.anyDefaultServer(
                        metadata.name,
                        vpnProtocol: selectedVPNProtocol
                    ) {
                        doSelectProvider(metadata, server)
                    } else {
                        errorMessage = L10n.AddProfile.Provider.Errors.noDefaultServer
                    }
                } catch {
                    errorMessage = error.localizedDescription
                }
                pendingOperation = nil
            }
        }

        private func doSelectProvider(_ metadata: ProviderMetadata, _ server: ProviderServer) {
            pendingProfile = Profile(metadata, server: server)
            selectedProvider = metadata
        }

        func updateIndex(_ providerManager: ProviderManager) {
            errorMessage = nil
            pendingOperation = .index
            Task { @MainActor in
                do {
                    try await providerManager.fetchProvidersIndexPublisher(
                        priority: .remoteThenBundle
                    ).async()
                } catch {
                    errorMessage = error.localizedDescription
                }
                pendingOperation = nil
            }
        }

        func presentPaywall() {
            isPaywallPresented = true
        }
    }
}

extension AddProviderView.NameView {
    struct ViewModel: Equatable {
        private var isNamePreset = false

        var profileName = ""

        var isAskingOverwrite = false

        private(set) var errorMessage: String?

        mutating func presetName(withMetadata metadata: ProviderMetadata) {
            guard !isNamePreset else {
                return
            }
            isNamePreset = true
            profileName = metadata.fullName
        }

        @MainActor
        mutating func addProfile(
            _ profile: Profile,
            to profileManager: ProfileManager,
            replacingExisting: Bool
        ) -> Profile? {
            profileName = profileName.stripped
            guard !profileName.isEmpty else {
                return nil
            }

            if !replacingExisting {
                guard !profileManager.isExistingProfile(withName: profileName) else {
                    isAskingOverwrite = true
                    return nil
                }
            }

            errorMessage = nil

            let finalProfile = profile.renamed(to: profileName)
            profileManager.saveProfile(finalProfile, isActive: nil)
            return finalProfile
        }

        private mutating func setMessage(forError error: Error) {
            errorMessage = error.localizedDescription
        }
    }
}

extension Profile {
    func renamed(to newName: String) -> Profile {
        var profile = self
        profile.header.name = newName
        return profile
    }
}
