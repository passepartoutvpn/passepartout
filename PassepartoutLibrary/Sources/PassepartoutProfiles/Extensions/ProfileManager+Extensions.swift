//
//  ProfileManager+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/22/22.
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
import PassepartoutCore

extension ProfileManager {
    public var hasProfiles: Bool {
        !profiles.isEmpty
    }

    public var activeProfile: Profile? {
        guard let id = activeProfileId else {
            return nil
        }
        return (try? liveProfileEx(withId: id))?.profile
    }

    public var hasActiveProfile: Bool {
        activeProfileId != nil
    }

    public func isActiveProfile(_ id: UUID) -> Bool {
        id == activeProfileId
    }

    public func activateProfile(_ profile: Profile) {
        saveProfile(profile, isActive: true, updateIfCurrent: true)
    }

    public func saveProfile(_ profile: Profile, isActive: Bool?) {
        saveProfile(profile, isActive: isActive, updateIfCurrent: true)
    }

    public func profile(withHeader header: Profile.Header, fromURL url: URL, passphrase: String?) throws -> Profile {
        let contents = try String(contentsOf: url)
        return try profile(withHeader: header, fromContents: contents, originalURL: url, passphrase: passphrase)
    }
}

extension ProfileManager {
    public func isCurrentProfileActive() -> Bool {
        currentProfile.value.id == activeProfileId
    }

    public func isCurrentProfile(_ id: UUID) -> Bool {
        id == currentProfile.value.id
    }

    public func activateCurrentProfile() {
        saveProfile(currentProfile.value, isActive: true, updateIfCurrent: false)
    }
}
