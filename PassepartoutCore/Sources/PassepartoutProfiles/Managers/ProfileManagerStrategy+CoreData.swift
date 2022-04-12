//
//  ProfileManagerStrategy+CoreData.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/9/22.
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
import PassepartoutUtils

extension ProfileManager {
    public class CoreDataStrategy: ProfileManagerStrategy {
        private let profileRepository: ProfileRepository

        private let fetchedHeaders: FetchedValueHolder<[UUID: Profile.Header]>

        public init(persistence: Persistence) {
            profileRepository = ProfileRepository(persistence.context)
            fetchedHeaders = profileRepository.headers()
        }
        
        public var allHeaders: [UUID: Profile.Header] {
            fetchedHeaders.value
        }
        
        public func profile(withId id: UUID) -> Profile? {
            profileRepository.profile(withId: id).value
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

        public func willUpdateProfiles() -> AnyPublisher<[UUID : Profile.Header], Never> {
            fetchedHeaders.$value
                .eraseToAnyPublisher()
        }
    }
}
