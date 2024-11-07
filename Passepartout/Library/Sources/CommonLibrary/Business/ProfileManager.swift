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

import Combine
import Foundation
import PassepartoutKit

@MainActor
public final class ProfileManager: ObservableObject {
    public enum Event {
        case save(Profile)

        case remove([Profile.ID])
    }

    private let repository: any ProfileRepository

    private let backupRepository: (any ProfileRepository)?

    private let remoteRepository: (any ProfileRepository)?

    private let deletingRemotely: Bool

    private let processor: ProfileProcessor?

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
        repository = InMemoryProfileRepository(profiles: profiles)
        backupRepository = nil
        remoteRepository = nil
        deletingRemotely = false
        processor = nil
        self.profiles = []
        allProfiles = profiles.reduce(into: [:]) {
            $0[$1.id] = $1
        }
        allRemoteProfiles = [:]

        didChange = PassthroughSubject()
        searchSubject = CurrentValueSubject("")
        subscriptions = []
    }

    public init(
        repository: any ProfileRepository,
        backupRepository: (any ProfileRepository)? = nil,
        remoteRepository: (any ProfileRepository)?,
        deletingRemotely: Bool = false,
        processor: ProfileProcessor? = nil
    ) {
        precondition(!deletingRemotely || remoteRepository != nil, "deletingRemotely requires a non-nil remoteRepository")
        self.repository = repository
        self.backupRepository = backupRepository
        self.remoteRepository = remoteRepository
        self.deletingRemotely = deletingRemotely
        self.processor = processor
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

    public func save(_ originalProfile: Profile, force: Bool = false, isShared: Bool? = nil) async throws {
        let profile: Profile
        if force {
            var builder = originalProfile.builder()
            if let processor {
                builder = try processor.willSave(builder)
            }
            builder.attributes.lastUpdate = Date()
            builder.attributes.fingerprint = UUID()
            profile = try builder.tryBuild()
        } else {
            profile = originalProfile
        }

        pp_log(.App.profiles, .notice, "Save profile \(profile.id)...")
        do {
            let existingProfile = allProfiles[profile.id]
            if existingProfile == nil || profile != existingProfile {
                try await repository.saveProfile(profile)
                if let backupRepository {
                    Task.detached {
                        try await backupRepository.saveProfile(profile)
                    }
                }
                allProfiles[profile.id] = profile
                didChange.send(.save(profile))
            } else {
                pp_log(.App.profiles, .notice, "\tProfile \(profile.id) not modified, not saving")
            }
        } catch {
            pp_log(.App.profiles, .fault, "\tUnable to save profile \(profile.id): \(error)")
            throw error
        }
        do {
            if let isShared, let remoteRepository {
                if isShared {
                    pp_log(.App.profiles, .notice, "\tEnable remote sharing of profile \(profile.id)...")
                    try await remoteRepository.saveProfile(profile)
                } else {
                    pp_log(.App.profiles, .notice, "\tDisable remote sharing of profile \(profile.id)...")
                    try await remoteRepository.removeProfiles(withIds: [profile.id])
                }
            }
        } catch {
            pp_log(.App.profiles, .fault, "\tUnable to save/remove remote profile \(profile.id): \(error)")
            throw error
        }
        pp_log(.App.profiles, .notice, "Finished saving profile \(profile.id)")
    }

    public func remove(withId profileId: Profile.ID) async {
        await remove(withIds: [profileId])
    }

    public func remove(withIds profileIds: [Profile.ID]) async {
        pp_log(.App.profiles, .notice, "Remove profiles \(profileIds)...")
        do {
            // remove local profiles
            var newAllProfiles = allProfiles
            try await repository.removeProfiles(withIds: profileIds)
            profileIds.forEach {
                newAllProfiles.removeValue(forKey: $0)
            }

            // remove remote counterpart too
            try? await remoteRepository?.removeProfiles(withIds: profileIds)
            profileIds.forEach {
                allRemoteProfiles.removeValue(forKey: $0)
            }

            // publish update
            allProfiles = newAllProfiles
            didChange.send(.remove(profileIds))
        } catch {
            pp_log(.App.profiles, .fault, "Unable to remove profiles \(profileIds): \(error)")
        }
    }

    public func exists(withId profileId: Profile.ID) -> Bool {
        allProfiles.keys.contains(profileId)
    }
}

// MARK: - Remote/Attributes

extension ProfileManager {
    public func isRemotelyShared(profileWithId profileId: Profile.ID) -> Bool {
        allRemoteProfiles.keys.contains(profileId)
    }

    public func isAvailableForTV(profileWithId profileId: Profile.ID) -> Bool {
        profile(withId: profileId)?.attributes.isAvailableForTV == true
    }

    public func eraseRemotelySharedProfiles() async throws {
        pp_log(.App.profiles, .notice, "Erase remotely shared profiles...")
        try await remoteRepository?.removeAllProfiles()
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
        pp_log(.App.profiles, .notice, "Duplicate profile [\(profileId), \(profile.name)] -> [\(builder.id), \(builder.name)]...")
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
            .profilesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reloadLocalProfiles($0)
            }
            .store(in: &subscriptions)

        // observe remote after first local profiles
        let remotePublisher = remoteRepository?
            .profilesPublisher
            .zip(repository.profilesPublisher)

        remotePublisher?
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] remote, _ in
                self?.loadInitialRemoteProfiles(remote)
            }
            .store(in: &subscriptions)

        remotePublisher?
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] remote, _ in
                self?.reloadRemoteProfiles(remote)
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
    func reloadLocalProfiles(_ result: [Profile]) {
        pp_log(.App.profiles, .info, "Reload local profiles: \(result.map(\.id))")
        allProfiles = result.reduce(into: [:]) {
            $0[$1.id] = $1
        }

        // should not be imported at all, but you never know
        if let isIncluded = processor?.isIncluded {
            let idsToRemove: [Profile.ID] = allProfiles
                .filter {
                    !isIncluded($0.value)
                }
                .map(\.key)

            if !idsToRemove.isEmpty {
                pp_log(.App.profiles, .info, "Delete non-included local profiles: \(idsToRemove)")
                Task.detached {
                    try await self.repository.removeProfiles(withIds: idsToRemove)
                }
            }
        }
    }

    func loadInitialRemoteProfiles(_ result: [Profile]) {
        pp_log(.App.profiles, .info, "Load initial remote profiles: \(result.map(\.id))")
        allRemoteProfiles = result.reduce(into: [:]) {
            $0[$1.id] = $1
        }
        objectWillChange.send()
    }

    func reloadRemoteProfiles(_ result: [Profile]) {
        pp_log(.App.profiles, .info, "Reload remote profiles: \(result.map(\.id))")
        allRemoteProfiles = result.reduce(into: [:]) {
            $0[$1.id] = $1
        }
        objectWillChange.send()

        Task.detached { [weak self] in
            guard let self else {
                return
            }

            pp_log(.App.profiles, .info, "Start importing remote profiles...")

            pp_log(.App.profiles, .debug, "Local fingerprints:")
            let localFingerprints: [Profile.ID: UUID] = await allProfiles.values.reduce(into: [:]) {
                $0[$1.id] = $1.attributes.fingerprint
                pp_log(.App.profiles, .debug, "\t\($1.id) = \($1.attributes.fingerprint?.description ?? "nil")")
            }
            pp_log(.App.profiles, .debug, "Remote fingerprints:")
            let remoteFingerprints: [Profile.ID: UUID] = result.reduce(into: [:]) {
                $0[$1.id] = $1.attributes.fingerprint
                pp_log(.App.profiles, .debug, "\t\($1.id) = \($1.attributes.fingerprint?.description ?? "nil")")
            }

            let profilesToImport = result
            let remotelyDeletedIds = await Set(allProfiles.keys).subtracting(Set(allRemoteProfiles.keys))
            let deletingRemotely = deletingRemotely

            var idsToRemove: [Profile.ID] = []
            if !remotelyDeletedIds.isEmpty {
                pp_log(.App.profiles, .info, "Will \(deletingRemotely ? "delete" : "retain") local profiles not present in remote repository: \(remotelyDeletedIds)")

                if deletingRemotely {
                    idsToRemove.append(contentsOf: remotelyDeletedIds)
                }
            }
            for remoteProfile in profilesToImport {
                do {
                    guard processor?.isIncluded(remoteProfile) ?? true else {
                        pp_log(.App.profiles, .info, "Will delete non-included remote profile \(remoteProfile.id)")
                        idsToRemove.append(remoteProfile.id)
                        continue
                    }
                    guard remoteFingerprints[remoteProfile.id] != localFingerprints[remoteProfile.id] else {
                        pp_log(.App.profiles, .info, "Skip re-importing local profile \(remoteProfile.id)")
                        continue
                    }
                    pp_log(.App.profiles, .notice, "Import remote profile \(remoteProfile.id)...")
                    try await save(remoteProfile)
                } catch {
                    pp_log(.App.profiles, .error, "Unable to import remote profile: \(error)")
                }
            }
            pp_log(.App.profiles, .notice, "Finished importing remote profiles, delete stale profiles: \(idsToRemove)")
            try? await repository.removeProfiles(withIds: idsToRemove)
        }
    }

    func performSearch(_ search: String) {
        pp_log(.App.profiles, .notice, "Filter profiles with '\(search)'")
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
