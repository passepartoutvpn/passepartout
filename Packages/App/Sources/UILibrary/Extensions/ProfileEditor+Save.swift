//
//  ProfileEditor+Save.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/10/25.
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
import Foundation

extension ProfileEditor {
    public func load(_ profile: EditableProfile, isShared: Bool) {
        editableProfile = profile
        self.isShared = isShared
        removedModules = [:]
    }

    public func save(
        to profileManager: ProfileManager,
        buildingWith registry: Registry,
        verifyingWith iapManager: IAPManager?,
        additionalFeatures: Set<AppFeature>? = nil,
        preferencesManager: PreferencesManager
    ) async throws -> Profile {
        let profileToSave = try build(with: registry)

        // verify profile (optional)
        if let iapManager, !iapManager.isBeta {
            do {
                try iapManager.verify(profileToSave, extra: extraFeatures.union(additionalFeatures ?? []))
            } catch AppError.ineligibleProfile(let requiredFeatures) {

                // still loading receipt
                guard !iapManager.isLoadingReceipt else {
                    throw AppError.verificationReceiptIsLoading
                }

                // purchase required
                guard requiredFeatures.isEmpty else {
                    throw AppError.verificationRequiredFeatures(requiredFeatures)
                }
            }
        }

        // persist
        try await profileManager.save(profileToSave, isLocal: true, remotelyShared: isShared)

        // clean up module preferences
        removedModules.keys.forEach {
            do {
                pp_log_g(.App.profiles, .info, "Erase preferences for removed module \($0)")
                let repository = try preferencesManager.preferencesRepository(forModuleWithId: $0)
                repository.erase()
                try repository.save()
            } catch {
                pp_log_g(.App.profiles, .error, "Unable to erase preferences for removed module \($0): \(error)")
            }
        }
        removedModules.removeAll()

        return profileToSave
    }
}

private extension ProfileEditor {
    var extraFeatures: Set<AppFeature> {
        var list: Set<AppFeature> = []
        if isShared {
            list.insert(.sharing)
            if isAvailableForTV {
                list.insert(.appleTV)
            }
        }
        return list
    }
}
