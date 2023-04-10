//
//  CoreDataProfileManagerStrategy.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/9/22.
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
import Combine
import PassepartoutCore
import PassepartoutUtils

public class CoreDataProfileManagerStrategy: ProfileManagerStrategy {
    private let profileRepository: ProfileRepository

    private let fetchedProfiles: FetchedValueHolder<[UUID: Profile]>

    public init(persistence: Persistence) {
        profileRepository = ProfileRepository(persistence.context)
        fetchedProfiles = profileRepository.fetchedProfiles()
    }

    public var allProfiles: [UUID: Profile] {
        fetchedProfiles.value
    }

    public func profiles() -> [Profile] {
        profileRepository.profiles()
    }

    public func profile(withId id: UUID) -> Profile? {
        profileRepository.profile(withId: id)
    }

    public func saveProfiles(_ profiles: [Profile]) {
        do {
            try profileRepository.saveProfiles(profiles)
        } catch {
            pp_log.error("Unable to save profile: \(error)")
        }
    }

    public func removeProfiles(withIds ids: [UUID]) {
        profileRepository.removeProfiles(withIds: ids)
    }

    public func willUpdateProfiles() -> AnyPublisher<[UUID: Profile], Never> {
        fetchedProfiles.$value
            .eraseToAnyPublisher()
    }
}
