//
//  NEProfileRepository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/10/24.
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

import AppData
import Combine
import Foundation
import PassepartoutKit
import UtilsLibrary

public final class NEProfileRepository: ProfileRepository {
    private let repository: NETunnelManagerRepository

    private let profilesSubject: CurrentValueSubject<[Profile], Never>

    private var subscriptions: Set<AnyCancellable>

    public init(repository: NETunnelManagerRepository) {
        self.repository = repository
        profilesSubject = CurrentValueSubject([])
        subscriptions = []

        repository
            .managersPublisher
            .sink { [weak self] allManagers in
                let profiles = allManagers.values.compactMap {
                    try? repository.profile(from: $0)
                }
                self?.profilesSubject.send(profiles)
            }
            .store(in: &subscriptions)

        Task {
            do {
                try await repository.load()
            } catch {
                pp_log(.app, .fault, "Unable to load NE profiles: \(error)")
            }
        }
    }

    public var entitiesPublisher: AnyPublisher<EntitiesResult<Profile>, Never> {
        profilesSubject
            .map {
                EntitiesResult($0, isFiltering: false)
            }
            .eraseToAnyPublisher()
    }

    public func filter(byFormat format: String, arguments: [Any]?) async throws {
        assertionFailure("Unused by ProfileManager")
    }

    public func resetFilter() async throws {
        assertionFailure("Unused by ProfileManager")
    }

    public func saveEntities(_ entities: [Profile]) async throws {
        for profile in entities {
            try await repository.save(profile, connect: false, title: \.name)
        }
    }

    public func removeEntities(withIds ids: [UUID]) async throws {
        for profileId in ids {
            try await repository.remove(profileId: profileId)
        }
    }
}
