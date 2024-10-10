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
import UtilsLibrary

public final class InMemoryProfileRepository: ProfileRepository {
    private var profiles: [Profile] {
        didSet {
            profilesSubject.send(EntitiesResult(profiles, isFiltering: false))
        }
    }

    private let profilesSubject: CurrentValueSubject<EntitiesResult<Profile>, Never>

    public init(profiles: [Profile] = []) {
        self.profiles = profiles
        profilesSubject = CurrentValueSubject(EntitiesResult(profiles, isFiltering: false))
    }

    public var entitiesPublisher: AnyPublisher<EntitiesResult<Profile>, Never> {
        profilesSubject
            .map {
                EntitiesResult($0.entities.sorted {
                    $0.name < $1.name
                }, isFiltering: $0.isFiltering)
            }
            .eraseToAnyPublisher()
    }

    public func filter(byFormat format: String, arguments: [Any]?) {
        print("Filter by format '\(format)' with \(arguments ?? [])")
        guard let nameSearch = arguments?.first as? String, !nameSearch.isEmpty else {
            profilesSubject.send(EntitiesResult(profiles, isFiltering: false))
            return
        }
        let match = nameSearch.lowercased()
        let filtered = profiles.filter {
            $0.name.lowercased().contains(match)
        }
        profilesSubject.send(EntitiesResult(filtered, isFiltering: true))
    }

    public func resetFilter() {
        print("Reset filter")
        profilesSubject.send(EntitiesResult(profiles, isFiltering: false))
    }

    public func saveEntities(_ entities: [Profile]) {
        print("Save entities: \(entities.map(\.id))")
        entities.forEach { profile in
            if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
                profiles[index] = profile
            } else {
                profiles.append(profile)
            }
        }
    }

    public func removeEntities(withIds ids: [UUID]) {
        print("Remove entities: \(ids)")
        profiles = profiles.filter {
            !ids.contains($0.id)
        }
    }
}
