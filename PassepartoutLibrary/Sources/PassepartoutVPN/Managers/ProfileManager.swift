//
//  ProfileManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/25/22.
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
import PassepartoutCore
import PassepartoutProviders

@MainActor
public final class ProfileManager: ObservableObject {
    public typealias ProfileEx = (profile: Profile, isReady: Bool)

    public typealias KeychainEntry = (Profile) -> String

    public typealias KeychainLabel = (Profile) -> String

    // MARK: Initialization

    private let store: KeyValueStore

    private let providerManager: ProviderManager

    private var profileRepository: ProfileRepository

    private var sharedProfileRepository: ProfileRepository?

    private let keychain: SecretRepository

    private let keychainEntry: (Profile) -> String

    private let keychainLabel: (Profile) -> String

    public var willSaveSharedProfile: (_ newProfile: Profile, _ existingProfile: Profile?) -> Profile

    // MARK: State

    @Published private var internalActiveProfileId: UUID? {
        willSet {
            pp_log.debug("Setting active profile: \(newValue?.uuidString ?? "nil")")
        }
    }

    @Published private var internalCurrentProfileId: UUID? {
        willSet {
            pp_log.debug("Setting current profile: \(newValue?.uuidString ?? "nil")")
        }
    }

    public var currentProfileId: UUID? {
        get {
            internalCurrentProfileId
        }
        set {
            guard let id = newValue else {
                internalCurrentProfileId = nil
                return
            }
            guard let profile = liveProfile(withId: id) else {
                return
            }
            internalCurrentProfileId = id
            setCurrentProfile(profile)
        }
    }

    public let currentProfile: ObservableProfile

    public let didUpdateProfiles = PassthroughSubject<Void, Never>()

    public let didUpdateActiveProfile = PassthroughSubject<UUID?, Never>()

    public let didCreateProfile = PassthroughSubject<Profile, Never>()

    @Published private var sharedProfileIds: Set<UUID> {
        didSet {
            refreshSharedProfiles()
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    public init(
        store: KeyValueStore,
        providerManager: ProviderManager,
        profileRepository: ProfileRepository,
        sharedProfileRepository: ProfileRepository? = nil,
        keychain: SecretRepository,
        keychainEntry: @escaping KeychainEntry,
        keychainLabel: @escaping KeychainLabel
    ) {
        self.store = store
        self.providerManager = providerManager
        self.profileRepository = profileRepository
        self.sharedProfileRepository = sharedProfileRepository
        self.keychain = keychain
        self.keychainEntry = keychainEntry
        self.keychainLabel = keychainLabel
        willSaveSharedProfile = { newProfile, _ in
            newProfile
        }

        currentProfile = ObservableProfile()
        if let sharedProfileRepository {
            sharedProfileIds = Set(sharedProfileRepository.allProfiles().keys)
        } else {
            sharedProfileIds = []
        }
    }
}

// MARK: Index

extension ProfileManager {
    public var allProfiles: [UUID: Profile] {
        profileRepository.allProfiles()
    }

    public var profiles: [Profile] {
        Array(allProfiles.values)
    }

    public var headers: [Profile.Header] {
        Array(allProfiles.values.map(\.header))
    }

    public func isExistingProfile(withId id: UUID) -> Bool {
        allProfiles[id] != nil
    }

    public func isExistingProfile(withName name: String) -> Bool {
        allProfiles.contains {
            $0.value.header.name == name
        }
    }
}

// MARK: Profiles

extension ProfileManager {
    public func liveProfileEx(withId id: UUID) throws -> ProfileEx {
        guard let profile = liveProfile(withId: id) else {
            pp_log.error("Profile not found: \(id)")
            throw Passepartout.ProfileError.notFound(profileId: id)
        }
        pp_log.info("Found profile: \(profile.logDescription)")
        return (profile, isProfileReady(profile))
    }

    private func liveProfile(withId id: UUID) -> Profile? {
        pp_log.debug("Searching profile \(id)")

        // IMPORTANT: fetch live copy first (see intents)
        if isCurrentProfile(id) {
            pp_log.debug("Profile \(currentProfile.value.logDescription) found in memory (current profile)")
            return currentProfile.value
        }

        guard let profile = profileRepository.profile(withId: id) else {
            assertionFailure("Profile in headers yet not found in persistent store")
            return nil
        }
        guard !profile.vpnProtocols.isEmpty else {
            assertionFailure("Ditching profile, no OpenVPN/WireGuard settings found")
            return nil
        }

        pp_log.debug("Profile \(profile.logDescription) found")
        keychain.debugAllPasswords(matching: id)

        return profile
    }

    public func activateProfile(_ profile: Profile, isActive: Bool) {
        guard !profile.isPlaceholder else {
            assertionFailure("Placeholder")
            return
        }

        if isActive {
            pp_log.info("\tActivating profile...")
            activeProfileId = profile.id
        } else if activeProfileId == profile.id {
            pp_log.info("\tDeactivating profile...")
            activeProfileId = nil
        }
    }

    public func saveProfile(_ profile: Profile, isActive: Bool?, updateIfCurrent: Bool = true) {
        guard !profile.isPlaceholder else {
            assertionFailure("Placeholder")
            return
        }

        pp_log.info("Writing profile \(profile.logDescription) to persistent store")
        saveProfilesAndLog([profile])

        if let isActive {
            activateProfile(profile, isActive: isActive)
        } else if allProfiles.isEmpty {
            pp_log.info("\tActivating first profile...")
            activeProfileId = profile.id
        }

        // IMPORTANT: refresh live copy if just saved (e.g. via intents)
        if updateIfCurrent && isCurrentProfile(profile.id) {
            pp_log.info("Saved profile is also current profile, updating...")
            currentProfile.value = profile
        }
    }

    public func removeProfiles(withIds ids: [UUID]) {
        pp_log.info("Deleting profiles with ids \(ids)")

        pp_log.info("\tDeleting passwords from keychain...")
        for id in ids {
            keychain.removeAllPasswords(matching: id)
        }

        pp_log.info("\tDeleting from persistent store...")
        profileRepository.removeProfiles(withIds: ids)
    }

    @available(*, deprecated, message: "Only use for testing")
    public func removeAllProfiles() {
        let ids = Array(allProfiles.keys)
        removeProfiles(withIds: ids)
    }

    public func duplicateProfile(withId id: UUID, setAsCurrent: Bool) {
        guard let source = liveProfile(withId: id) else {
            return
        }
        let copy = source
            .withNewId()
            .renamedUniquely(withLastUpdate: false)

        if setAsCurrent {

            // iOS 14 goes crazy when changing binding of a presented NavigationLink
            internalCurrentProfileId = copy.id

            // autosaves copy if non-existing in persistent store
            setCurrentProfile(copy)
        } else {
            saveProfilesAndLog([copy])
        }
    }

    public func persist() {
        pp_log.info("Persisting pending profiles")
        if !currentProfile.value.isPlaceholder {
            saveProfile(currentProfile.value, isActive: nil, updateIfCurrent: false)
        }
    }
}

// MARK: Keychain

extension ProfileManager {
    public func savePassword(forProfile profile: Profile, newPassword: String? = nil) {
        guard !profile.isPlaceholder else {
            assertionFailure("Placeholder")
            return
        }
        let entry = keychainEntry(profile)
        let password = newPassword ?? profile.account.password
        guard !password.isEmpty else {
            keychain.removePassword(
                for: entry,
                userDefined: profile.id.uuidString
            )
            return
        }
        do {
            try keychain.set(
                password: password,
                for: entry,
                userDefined: profile.id.uuidString,
                label: keychainLabel(profile)
            )
        } catch {
            pp_log.error("Unable to save password to keychain: \(error)")
        }
    }

    public func passwordReference(forProfile profile: Profile) -> Data? {
        guard !profile.isPlaceholder else {
            assertionFailure("Placeholder")
            return nil
        }
        let entry = keychainEntry(profile)
        do {
            return try keychain.passwordReference(
                for: entry,
                userDefined: profile.id.uuidString
            )
        } catch {
            pp_log.debug("Unable to load password reference from keychain: \(error)")
            return nil
        }
    }
}

// MARK: Observation

extension ProfileManager {
    private func setCurrentProfile(_ profile: Profile) {
        guard !currentProfile.isLoading else {
            pp_log.warning("Already loading another profile")
            return
        }
        guard profile.id != currentProfile.value.id else {
            pp_log.debug("Profile \(profile.logDescription) is already current profile")
            return
        }

        pp_log.info("Set current profile: \(profile.logDescription)")

        //
        // IMPORTANT: this method is called on app launch if there is an active profile, which
        // means that carelessly calling .saveProfiles() may trigger an unnecessary
        // willUpdateProfiles() and a potential animation in subscribers (e.g. OrganizerView)
        //
        // current profile, when set on launch, is always existing, so we take care
        // checking that to avoid an undesired save
        //
        var profilesToSave: [Profile] = []
        if isExistingProfile(withId: currentProfile.value.id) {
            pp_log.info("Defer saving of former current profile \(currentProfile.value.logDescription)")
            profilesToSave.append(currentProfile.value)
        }
        if !isExistingProfile(withId: profile.id) {
            pp_log.info("Defer saving of transient current profile \(profile.logDescription)")
            profilesToSave.append(profile)
        }
        defer {
            if !profilesToSave.isEmpty {
                saveProfilesAndLog(profilesToSave)
            }
        }

        if isProfileReady(profile) {
            currentProfile.value = profile
        } else {
            currentProfile.isLoading = true
            Task {
                try await makeProfileReady(profile)
                currentProfile.value = profile
                currentProfile.isLoading = false
            }
        }
    }
}

extension ProfileManager {
    public func observeUpdates() {
        $internalActiveProfileId
            .sink { [weak self] in
                self?.didUpdateActiveProfile.send($0)
            }
            .store(in: &cancellables)

        profileRepository.willUpdateProfiles()
            .dropFirst()
            .sink { [weak self] in
                self?.willUpdateProfiles($0)
            }
            .store(in: &cancellables)

        if let sharedProfileRepository {

            // persist changes to shared profiles immediately
            currentProfile.$value
                .dropFirst()
                .removeDuplicates()
                .filter { [unowned self] in
                    sharedProfileIds.contains($0.id)
                }
                .map { [unowned self] in
                    let existingProfile = sharedProfileRepository.profile(withId: $0.id)
                    return willSaveSharedProfile($0, existingProfile)
                }
                .sink { newSharedProfile in
                    do {
                        try sharedProfileRepository.saveProfiles([newSharedProfile])
                        pp_log.info("Current profile persisted (shared): \(newSharedProfile.logDescription)")
                    } catch {
                        pp_log.error("Unable to persist current profile (shared): \(error)")
                    }
                }
                .store(in: &cancellables)
        }
    }

    private func willUpdateProfiles(_ newProfiles: [UUID: Profile]) {
        pp_log.debug("Profiles updated: \(newProfiles.values.map(\.header))")
        defer {
            objectWillChange.send()
        }

        // IMPORTANT: invalidate current profile if deleted
        if !currentProfile.value.isPlaceholder && !newProfiles.keys.contains(currentProfile.value.id) {
            pp_log.info("\tCurrent profile deleted, invalidating...")
            currentProfile.value = .placeholder
        }

        if let newProfile = newProfiles[currentProfile.value.id], newProfile != currentProfile.value {
            pp_log.info("Current profile remotely updated")
            currentProfile.value = newProfile
        }

        if let activeProfileId = activeProfileId, !newProfiles.keys.contains(activeProfileId) {
            pp_log.info("\tActive profile was deleted")
            self.activeProfileId = nil
        }

        didUpdateProfiles.send()

        // IMPORTANT: defer task to avoid recursive saves (is non-main thread an issue?)
        // FIXME: Core Data, not sure about this workaround
        Task {
            fixDuplicateNames(in: newProfiles)
        }
    }

    private func fixDuplicateNames(in newProfiles: [UUID: Profile]) {
        var allNames = newProfiles.values.map(\.header.name)
        let distinctNames = Set(allNames)
        distinctNames.forEach {
            guard let i = allNames.firstIndex(of: $0) else {
                return
            }
            allNames.remove(at: i)
        }
        let duplicates = Set(allNames)
        guard !duplicates.isEmpty else {
            pp_log.debug("No duplicated profiles")
            return
        }
        pp_log.debug("Duplicated profile names: \(duplicates)")

        var renamedProfiles: [Profile] = []
        duplicates.forEach { name in
            let headers = newProfiles.values
                .map(\.header)
                .filter {
                    $0.name == name
                }
            guard headers.count > 1 else {
                assertionFailure("Name '\(name)' marked as duplicate but headers.count not > 1")
                return
            }

//            headers.removeFirst()
            headers.forEach { dupHeader in
                let uniqueHeader = dupHeader.renamedUniquely(withLastUpdate: true)
                pp_log.debug("Renaming duplicate profile \(dupHeader.logDescription) to \(uniqueHeader.logDescription)")
                guard var uniqueProfile = liveProfile(withId: uniqueHeader.id) else {
                    pp_log.warning("Skipping profile \(dupHeader.logDescription) renaming, not found")
                    return
                }
                uniqueProfile.header = uniqueHeader
                renamedProfiles.append(uniqueProfile)
            }
        }
        if !renamedProfiles.isEmpty {
            saveProfilesAndLog(renamedProfiles)
            pp_log.debug("Duplicates successfully renamed!")
        }
    }
}

// MARK: Persistence

extension ProfileManager {
    private func saveProfilesAndLog(_ profiles: [Profile]) {
        do {
            try profileRepository.saveProfiles(profiles.map {
                var copy = $0
                copy.connectionExpirationDate = nil
                return copy
            })
        } catch {
            pp_log.error("Unable to save profile(s): \(error)")
        }
    }

    public func isSharing(profile: Profile) -> Bool {
        sharedProfileIds.contains(profile.id)
    }

    public func setSharing(_ isShared: Bool, profile: Profile) {
        if isShared {
            pp_log.debug("Adding shared profile: \(profile.id)")
            sharedProfileIds.insert(profile.id)
        } else {
            pp_log.debug("Removing shared profile: \(profile.id))")
            sharedProfileIds.remove(profile.id)
        }
    }
}

extension ProfileManager {
    public func refreshSharedProfiles() {
        guard let sharedProfileRepository else {
            return
        }

        var toAdd: [Profile] = []
        var toRemove: [UUID] = []
        profiles.forEach {
            if sharedProfileIds.contains($0.id) {
                toAdd.append($0)
            } else {
                toRemove.append($0.id)
            }
        }

        let existingProfiles = sharedProfileRepository
            .allProfiles()
            .filter {
                sharedProfileIds.contains($0.key)
            }

        pp_log.debug("Refreshing shared profiles")
        pp_log.debug("\tAdding: \(toAdd.map(\.logDescription))")
        pp_log.debug("\tExisting: \(existingProfiles.keys)")
        pp_log.debug("\tRemoving: \(toRemove)")

        sharedProfileRepository.removeProfiles(withIds: toRemove)
        do {
            try sharedProfileRepository.saveProfiles(toAdd.map {
                willSaveSharedProfile($0, existingProfiles[$0.id])
            })
        } catch {
            pp_log.error("Unable to save shared profiles: \(error)")
        }
    }
}

// MARK: Readiness

extension ProfileManager {
    private func isProfileReady(_ profile: Profile) -> Bool {
        isProfileProviderAvailable(profile)
    }

    public func makeProfileReady(_ profile: Profile) async throws {
        try await fetchProfileProviderIfMissing(profile)
    }

    private func isProfileProviderAvailable(_ profile: Profile) -> Bool {
        guard let providerName = profile.header.providerName else {
            return true // host
        }
        return providerManager.isAvailable(providerName, vpnProtocol: profile.currentVPNProtocol)
    }

    private func fetchProfileProviderIfMissing(_ profile: Profile) async throws {
        guard let providerName = profile.header.providerName else {
            return // host
        }
        if providerManager.isAvailable(providerName, vpnProtocol: profile.currentVPNProtocol) {
            return
        }
        do {
            pp_log.info("Importing missing provider \(providerName)...")
            try await providerManager.fetchProviderPublisher(
                withName: providerName,
                vpnProtocol: profile.currentVPNProtocol,
                priority: .remoteThenBundle
            ).async()
            pp_log.info("Finished!")
        } catch {
            pp_log.error("Unable to import missing provider: \(error)")
            throw Passepartout.ProfileError.failedToFetchProvider(profileId: profile.id, error: error)
        }
    }
}

// MARK: Repository

extension ProfileManager {
    public func swapProfileRepository(_ newProfileRepository: ProfileRepository) {
        cancellables.removeAll()

        objectWillChange.send()
        profileRepository = newProfileRepository
        observeUpdates()
    }
}

// MARK: KeyValueStore

extension ProfileManager {
    public private(set) var activeProfileId: UUID? {
        get {
            guard let idString: String = store.value(forLocation: StoreKey.activeProfileId) else {
                return nil
            }
            guard let id = UUID(uuidString: idString) else {
                pp_log.warning("Active profile id is malformed, ignoring")
                return nil
            }
            guard isExistingProfile(withId: id) else {
                pp_log.warning("Active profile \(id) does not exist, ignoring")
                return nil
            }
            return id
        }
        set {

            // trigger publisher
            internalActiveProfileId = newValue

            store.setValue(newValue?.uuidString, forLocation: StoreKey.activeProfileId)
        }
    }
}

private extension ProfileManager {
    enum StoreKey: String, KeyStoreDomainLocation {
        case activeProfileId

        var domain: String {
            "Passepartout.ProfileManager"
        }
    }
}
