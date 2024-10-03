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
import UtilsLibrary

@MainActor
public final class ProfileManager: ObservableObject {
    public enum Event {
        case save(Profile)

        case remove([Profile.ID])

//        case remoteUpdate([Profile])
    }

    public var beforeSave: ((Profile) async throws -> Void)?

    public var afterRemove: (([Profile.ID]) async -> Void)?

    private let repository: any ProfileRepository

    private let remoteRepository: (any ProfileRepository)?

    @Published
    private var profiles: [Profile]

    private var allProfiles: [Profile.ID: Profile] {
        didSet {
            reloadFilteredProfiles()
        }
    }

    private var allRemoteProfiles: [Profile.ID: Profile]

    public let didChange: PassthroughSubject<Event, Never>

    private let searchSubject: CurrentValueSubject<String, Never>

    private var subscriptions: Set<AnyCancellable>

    // for testing/previews
    public init(profiles: [Profile]) {
        repository = MockProfileRepository(profiles: profiles)
        remoteRepository = nil
        self.profiles = []
        allProfiles = profiles.reduce(into: [:]) {
            $0[$1.id] = $1
        }
        allRemoteProfiles = [:]

        didChange = PassthroughSubject()
        searchSubject = CurrentValueSubject("")
        subscriptions = []
    }

    public init(repository: any ProfileRepository, remoteRepository: (any ProfileRepository)?) {
        self.repository = repository
        self.remoteRepository = remoteRepository
        profiles = []
        allProfiles = [:]
        allRemoteProfiles = [:]

        didChange = PassthroughSubject()
        searchSubject = CurrentValueSubject("")
        subscriptions = []
    }
}

// MARK: - CRUD

extension ProfileManager {
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
            try await beforeSave?(profile)
            try await repository.saveEntities([profile])
            allProfiles[profile.id] = profile
            didChange.send(.save(profile))
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
            var newAllProfiles = allProfiles
            try await repository.removeEntities(withIds: profileIds)
            profileIds.forEach {
                newAllProfiles.removeValue(forKey: $0)
            }
            await afterRemove?(profileIds)
            allProfiles = newAllProfiles
            didChange.send(.remove(profileIds))
        } catch {
            pp_log(.app, .fault, "Unable to remove profiles \(profileIds): \(error)")
        }
    }

    public func exists(withId profileId: Profile.ID) -> Bool {
        allProfiles.keys.contains(profileId)
    }
}

// MARK: - Remote

extension ProfileManager {
    public func isRemotelyShared(profileWithId profileId: Profile.ID) -> Bool {
        allRemoteProfiles.keys.contains(profileId)
    }

    public func setRemotelyShared(_ shared: Bool, profileWithId profileId: Profile.ID) async throws {
        guard let remoteRepository else {
            pp_log(.app, .error, "Unable to share remotely when no remoteRepository is set")
            return
        }
        guard let profile = allProfiles[profileId] else {
            return
        }
        if shared {
            try await remoteRepository.saveEntities([profile])
        } else {
            try await remoteRepository.removeEntities(withIds: [profileId])
        }
    }
}

// MARK: - Shortcuts

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

// MARK: - Observation

extension ProfileManager {
    public func observeObjects(searchDebounce: Int = 200) {
        repository
            .entitiesPublisher
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.notifyLocalEntities($0)
            }
            .store(in: &subscriptions)

        remoteRepository?
            .entitiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.notifyRemoteEntities($0)
            }
            .store(in: &subscriptions)

        searchSubject
            .debounce(for: .milliseconds(searchDebounce), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.performSearch($0)
            }
            .store(in: &subscriptions)
    }
}

private extension ProfileManager {
    func notifyLocalEntities(_ result: EntitiesResult<Profile>) {
        allProfiles = result.entities.reduce(into: [:]) {
            $0[$1.id] = $1
        }
    }

    func notifyRemoteEntities(_ result: EntitiesResult<Profile>) {
        allRemoteProfiles = result.entities.reduce(into: [:]) {
            $0[$1.id] = $1
        }

        // pull remote updates into local profiles
        var newAllProfiles = allProfiles
        allRemoteProfiles.forEach {
            newAllProfiles[$0.key] = $0.value
        }
        allProfiles = newAllProfiles

//        let oldProfiles = profiles.reduce(into: [:]) {
//            $0[$1.id] = $1
//        }
//        let newProfiles = result.entities
//        let updatedProfiles = newProfiles.filter {
//            $0 != oldProfiles[$0.id] // includes new profiles
//        }
//        didChange.send(.remoteUpdate(updatedProfiles))
    }

    func performSearch(_ search: String) {
        reloadFilteredProfiles(with: search)
    }

    func reloadFilteredProfiles(with search: String? = nil) {
        profiles = allProfiles
            .values
            .filter {
                if let search, !search.isEmpty {
                    return $0.name.lowercased().contains(search.lowercased())
                }
                return true
            }
            .sorted {
                $0.name.lowercased() < $1.name.lowercased()
            }
    }
}
