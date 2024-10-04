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
    }

    public var beforeSave: ((Profile) async throws -> Void)?

    public var afterRemove: (([Profile.ID]) async -> Void)?

    private let repository: any ProfileRepository

    private let remoteRepository: (any ProfileRepository)?

    @Published
    private var profiles: [Profile]

    private var allProfiles: [Profile.ID: Profile] {
        didSet {
            reloadFilteredProfiles(with: searchSubject.value)
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

    public func save(_ profile: Profile, isShared: Bool? = nil) async throws {
        pp_log(.app, .notice, "Save profile \(profile.id)...")
        do {
            if let existingProfile = allProfiles[profile.id], profile != existingProfile {
               try await beforeSave?(profile)
               try await repository.saveEntities([profile])

                allProfiles[profile.id] = profile
                didChange.send(.save(profile))
            } else {
                pp_log(.app, .notice, "Profile \(profile.id) not modified, not saving")
            }
        } catch {
            pp_log(.app, .fault, "Unable to save profile \(profile.id): \(error)")
            throw error
        }
        do {
            if let isShared, let remoteRepository {
                if isShared {
                    pp_log(.app, .notice, "Enable remote sharing of profile \(profile.id)...")
                    try await remoteRepository.saveEntities([profile])
                } else {
                    pp_log(.app, .notice, "Disable remote sharing of profile \(profile.id)...")
                    try await remoteRepository.removeEntities(withIds: [profile.id])
                }
            }
        } catch {
            pp_log(.app, .fault, "Unable to save/remove remote profile \(profile.id): \(error)")
            throw error
        }
    }

    public func remove(withId profileId: Profile.ID) async {
        await remove(withIds: [profileId])
    }

    public func remove(withIds profileIds: [Profile.ID]) async {
        pp_log(.app, .notice, "Remove profiles \(profileIds)...")
        do {
            // remove local profiles
            var newAllProfiles = allProfiles
            try await repository.removeEntities(withIds: profileIds)
            await afterRemove?(profileIds)
            profileIds.forEach {
                newAllProfiles.removeValue(forKey: $0)
            }

            // remove remote counterpart too
            try? await remoteRepository?.removeEntities(withIds: profileIds)
            profileIds.forEach {
                allRemoteProfiles.removeValue(forKey: $0)
            }

            // publish update
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

    public func eraseRemotelySharedProfiles() async throws {
        pp_log(.app, .notice, "Erase remotely shared profiles...")
        try await remoteRepository?.removeEntities(withIds: Array(allRemoteProfiles.keys))
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
        pp_log(.app, .notice, "Duplicate profile [\(profileId), \(profile.name)] -> [\(builder.id), \(builder.name)]...")
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
                self?.reloadLocalProfiles($0)
            }
            .store(in: &subscriptions)

        remoteRepository?
            .entitiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reloadRemoteProfiles($0)
            }
            .store(in: &subscriptions)

        remoteRepository?
            .entitiesPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.importRemoteProfiles($0)
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
    func reloadLocalProfiles(_ result: EntitiesResult<Profile>) {
        pp_log(.app, .info, "Reload local profiles: \(result.entities.map(\.id))")
        allProfiles = result.entities.reduce(into: [:]) {
            $0[$1.id] = $1
        }
    }

    func reloadRemoteProfiles(_ result: EntitiesResult<Profile>) {
        pp_log(.app, .info, "Reload remote profiles: \(result.entities.map(\.id))")
        allRemoteProfiles = result.entities.reduce(into: [:]) {
            $0[$1.id] = $1
        }
        objectWillChange.send()
    }

    // pull remote updates into local profiles (best-effort)
    func importRemoteProfiles(_ result: EntitiesResult<Profile>) {
        let profilesToImport = result.entities
        pp_log(.app, .info, "Try to import remote profiles: \(result.entities.map(\.id))")

        Task.detached { [weak self] in
            for remoteProfile in profilesToImport {
                do {
                    pp_log(.app, .notice, "Import remote profile \(remoteProfile.id)...")
                    try await self?.save(remoteProfile)
                } catch {
                    pp_log(.app, .error, "Unable to import remote profile: \(error)")
                }
            }
        }
    }

    func performSearch(_ search: String) {
        pp_log(.app, .notice, "Filter profiles with '\(search)'")
        reloadFilteredProfiles(with: search)
    }

    func reloadFilteredProfiles(with search: String) {
        profiles = allProfiles
            .values
            .filter {
                if !search.isEmpty {
                    return $0.name.lowercased().contains(search.lowercased())
                }
                return true
            }
            .sorted {
                $0.name.lowercased() < $1.name.lowercased()
            }
    }
}
