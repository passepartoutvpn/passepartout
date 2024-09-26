//
//  ProfileManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/24.
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

@MainActor
public final class ProfileManager: ObservableObject {
    public let didSave: PassthroughSubject<Profile, Never>

    public var didUpdate: AnyPublisher<[Profile], Never> {
        $profiles.eraseToAnyPublisher()
    }

    @Published
    var profiles: [Profile]

    private var allProfileIds: Set<Profile.ID>

    private let repository: any ProfileRepository

    private let searchSubject: CurrentValueSubject<String, Never>

    private var subscriptions: Set<AnyCancellable>

    // for testing/previews
    public init(profiles: [Profile]) {
        didSave = PassthroughSubject()
        self.profiles = profiles.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
        allProfileIds = []
        repository = MockProfileRepository(profiles: profiles)
        searchSubject = CurrentValueSubject("")
        subscriptions = []

        observeObjects(searchDebounce: 0)
    }

    public init(repository: any ProfileRepository, searchDebounce: Int = 200) {
        didSave = PassthroughSubject()
        profiles = []
        allProfileIds = []
        self.repository = repository
        searchSubject = CurrentValueSubject("")
        subscriptions = []

        observeObjects(searchDebounce: searchDebounce)
    }

    public var hasProfiles: Bool {
        !profiles.isEmpty
    }

    public var isSearching: Bool {
        !searchSubject.value.isEmpty
    }

    public var headers: [ProfileHeader] {
        profiles.map {
            $0.header()
        }
    }

    public func search(byName name: String) {
        searchSubject.send(name)
    }

    public func profile(withId profileId: Profile.ID) -> Profile? {
        profiles.first {
            $0.id == profileId
        }
    }

    public func save(_ profile: Profile) async throws {
        do {
            try await repository.saveEntities([profile])
            didSave.send(profile)
        } catch {
            pp_log(.app, .fault, "Unable to save profile \(profile.id): \(error)")
            throw error
        }
    }

    public func remove(withId profileId: Profile.ID) async {
        await remove(withIds: [profileId])
    }

    public func remove(withIds profileIds: [Profile.ID]) async {
        do {
            allProfileIds.subtract(profileIds)
            try await repository.removeEntities(withIds: profileIds)
        } catch {
            pp_log(.app, .fault, "Unable to remove profiles \(profileIds): \(error)")
        }
    }

    public func exists(withId profileId: Profile.ID) -> Bool {
        allProfileIds.contains(profileId)
    }
}

extension ProfileManager {
    public func new(withName name: String) -> Profile {
        var builder = Profile.Builder()
        builder.name = firstUniqueName(from: name)
        do {
            return try builder.tryBuild()
        } catch {
            fatalError("Unable to build new empty profile: \(error)")
        }
    }

    public func duplicate(profileWithId profileId: Profile.ID) async throws {
        guard let profile = profile(withId: profileId) else {
            return
        }

        var builder = profile.builder(withNewId: true)
        builder.name = firstUniqueName(from: profile.name)
        let copy = try builder.tryBuild()

        try await save(copy)
    }
}

private extension ProfileManager {
    func observeObjects(searchDebounce: Int) {
        repository
            .entitiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else {
                    return
                }
                self.profiles = $0.entities
                if !$0.isFiltering {
                    allProfileIds = Set($0.entities.map(\.id))
                }
            }
            .store(in: &subscriptions)

        searchSubject
            .debounce(for: .milliseconds(searchDebounce), scheduler: DispatchQueue.main)
            .sink { [weak self] search in
                Task {
                    guard !search.isEmpty else {
                        try await self?.repository.resetFilter()
                        return
                    }
                    try await self?.repository.filter(byName: search)
                }
            }
            .store(in: &subscriptions)
    }

    func firstUniqueName(from name: String) -> String {
        let allNames = profiles.map(\.name)
        var newName = name
        var index = 1
        while true {
            if !allNames.contains(newName) {
                return newName
            }
            newName = [name, index.description].joined(separator: ".")
            index += 1
        }
    }
}
