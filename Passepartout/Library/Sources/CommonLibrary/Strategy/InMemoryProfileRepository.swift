//
//  InMemoryProfileRepository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/11/24.
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

import Combine
import Foundation
import PassepartoutKit

public final class InMemoryProfileRepository: ProfileRepository {
    var profiles: [Profile] {
        didSet {
            profilesSubject.send(profiles)
        }
    }

    private let profilesSubject: CurrentValueSubject<[Profile], Never>

    public init(profiles: [Profile] = []) {
        self.profiles = profiles
        profilesSubject = CurrentValueSubject(profiles)
    }

    public var profilesPublisher: AnyPublisher<[Profile], Never> {
        profilesSubject.eraseToAnyPublisher()
    }

    public func fetchProfiles() async throws -> [Profile] {
        profiles
    }

    public func saveProfile(_ profile: Profile) {
        pp_log(.App.profiles, .info, "Save profile: \(profile.id)")
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
    }

    public func removeProfiles(withIds ids: [Profile.ID]) {
        pp_log(.App.profiles, .info, "Remove profiles: \(ids)")
        let newProfiles = profiles.filter {
            !ids.contains($0.id)
        }
        guard newProfiles.count < profiles.count else {
            return
        }
        profiles = newProfiles
    }

    public func removeAllProfiles() async throws {
        pp_log(.App.profiles, .info, "Remove all profiles")
        profiles = []
    }
}
