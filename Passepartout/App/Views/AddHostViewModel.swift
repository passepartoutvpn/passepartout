//
//  AddHostViewModel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/14/22.
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
import TunnelKitOpenVPN
import TunnelKitWireGuard

extension AddHostView {
    struct ViewModel: Equatable {
        private var isNamePreset = false

        var profileName = ""

        private(set) var requiresPassphrase = false

        var encryptionPassphrase = ""

        var processedProfile: Profile = .placeholder

        private(set) var errorMessage: String?

        var isAskingOverwrite = false

        mutating func presetName(withURL url: URL) {
            guard !isNamePreset else {
                return
            }
            isNamePreset = true
            profileName = url.filename
        }

        @MainActor
        mutating func processURL(
            _ url: URL,
            with profileManager: ProfileManager,
            replacingExisting: Bool,
            deletingURLOnSuccess: Bool
        ) {
            profileName = profileName.stripped
            guard !profileName.isEmpty else {
                return
            }

            if !replacingExisting {
                guard !profileManager.isExistingProfile(withName: profileName) else {
                    isAskingOverwrite = true
                    return
                }
            }

            errorMessage = nil
            do {
                let profile = try profileManager.profile(
                    withHeader: .init(name: profileName),
                    fromURL: url,
                    passphrase: encryptionPassphrase
                )
                processedProfile = profile

                if deletingURLOnSuccess {
                    try? FileManager.default.removeItem(at: url)
                }
            } catch {
                switch error {
                case OpenVPN.ConfigurationError.encryptionPassphrase,
                    OpenVPN.ConfigurationError.unableToDecrypt:

                    requiresPassphrase = true

                default:
                    requiresPassphrase = false
                }
                setMessage(forParsingError: error)
            }
        }

        @MainActor
        mutating func addProcessedProfile(to profileManager: ProfileManager) -> Bool {
            guard !processedProfile.isPlaceholder else {
                assertionFailure("Saving profile without processing first?")
                return false
            }
            errorMessage = nil
            profileManager.saveProfile(processedProfile, isActive: nil)
            return true
        }

        private mutating func setMessage(forParsingError error: Error) {
            errorMessage = error.localizedVPNParsingDescription
        }
    }
}
