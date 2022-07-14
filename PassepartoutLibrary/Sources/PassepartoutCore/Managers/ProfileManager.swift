//
//  ProfileManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/20/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import Combine

public protocol ProfileManager {
    typealias ProfileEx = (profile: Profile, isReady: Bool)
    
    var activeProfileId: UUID? { get }

    var currentProfileId: UUID? { get set }

    var didUpdateActiveProfile: PassthroughSubject<UUID?, Never> { get }

    var didCreateProfile: PassthroughSubject<Profile, Never> { get }
    
    var headers: [Profile.Header] { get }
    
    var profiles: [Profile] { get }
    
    func isExistingProfile(withId id: UUID) -> Bool
    
    func isExistingProfile(withName name: String) -> Bool

    func liveProfileEx(withId id: UUID) throws -> ProfileEx

    func makeProfileReady(_ profile: Profile) async throws

    func saveProfile(_ profile: Profile, isActive: Bool?, updateIfCurrent: Bool)
    
    func savePassword(forProfile profile: Profile)

    func passwordReference(forProfile profile: Profile) -> Data?

    func removeProfiles(withIds ids: [UUID])
    
    @available(*, deprecated, message: "only use for testing")
    func removeAllProfiles()
    
    func duplicateProfile(withId id: UUID, setAsCurrent: Bool)

    func profile(withHeader header: Profile.Header, fromContents contents: String, originalURL: URL?, passphrase: String?) throws -> Profile

    func persist()

    func observeUpdates()
}
