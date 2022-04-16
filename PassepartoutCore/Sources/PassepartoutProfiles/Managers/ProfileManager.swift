//
//  ProfileManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/25/22.
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
import TunnelKitManager
import PassepartoutProviders
import PassepartoutUtils

@MainActor
public class ProfileManager: ObservableObject {
    public typealias LoadResult = (isReady: Bool, profile: Profile)
    
    // MARK: Initialization
    
    private let providerManager: ProviderManager
    
    public let appGroup: String
    
    let keychainLabel: (String, VPNProtocolType) -> String
    
    let keychain: Keychain
    
    private let strategy: ProfileManagerStrategy
    
    public var availabilityFilter: ((Profile.Header) -> Bool)?

    public var activeProfileId: UUID? {
        willSet {
            willUpdateActiveId.send(newValue)
            objectWillChange.send()
        }
        didSet {
            pp_log.debug("Active profile updated: \(activeProfileId?.uuidString ?? "nil")")
        }
    }

    // MARK: Observables

    public let currentProfile: ObservableProfile
    
    public let willUpdateActiveId = PassthroughSubject<UUID?, Never>()

    public let willUpdateCurrentProfile = PassthroughSubject<Profile, Never>()

    public let didCreateProfile = PassthroughSubject<Profile, Never>()
    
    private var cancellables: Set<AnyCancellable> = []

    public init(
        providerManager: ProviderManager,
        appGroup: String,
        keychainLabel: @escaping (String, VPNProtocolType) -> String,
        strategy: ProfileManagerStrategy
    ) {
        guard let _ = UserDefaults(suiteName: appGroup) else {
            fatalError("No entitlements for group '\(appGroup)'")
        }
        self.providerManager = providerManager
        self.appGroup = appGroup
        self.keychainLabel = keychainLabel
        keychain = Keychain(group: appGroup)
        self.strategy = strategy

        currentProfile = ObservableProfile()
        observeUpdates()
    }
}

// MARK: Index

extension ProfileManager {
    private var allHeaders: [UUID: Profile.Header] {
        strategy.allHeaders
    }
    
    private var availableHeaders: [Profile.Header] {
        if let availabilityFilter = availabilityFilter {
            return allHeaders.values.filter(availabilityFilter)
        }
        return Array(allHeaders.values)
    }

    public var headers: [Profile.Header] {
        availableHeaders
    }

    public var activeHeader: Profile.Header? {
        availableHeaders.first {
            $0.id == activeProfileId
        }
    }

    public func isActiveProfile(_ id: UUID) -> Bool {
        id == activeProfileId
    }
    
    // existence in persistent storage (skips availability)
    public func isExistingProfile(withId id: UUID) -> Bool {
        allHeaders[id] != nil
    }
    
    // existence in persistent storage (skips availability)
    public func isExistingProfile(withName name: String) -> Bool {
        allHeaders.contains {
            $0.value.name == name
        }
    }
}

// MARK: Profiles

extension ProfileManager {
    public var activeProfile: Profile? {
        guard let activeHeader = activeHeader else {
            return nil
        }
        return profile(withId: activeHeader.id)
    }

    public func activateProfile(_ profile: Profile) {
        saveProfile(profile, isActive: true)
    }

    public func loadProfile(withId id: UUID) throws -> LoadResult {
        guard let profile = profile(withId: id) else {
            pp_log.error("Profile not found: \(id)")
            throw PassepartoutError.missingProfile
        }
        pp_log.info("Found profile: \(profile.logDescription)")
        return (isProfileReady(profile), profile)
    }

    private func profile(withId id: UUID) -> Profile? {
        pp_log.debug("Searching profile \(id)")

        // IMPORTANT: fetch live copy first (see intents)
        if isCurrentProfile(id) {
            pp_log.debug("Profile \(currentProfile.value.logDescription) found in memory")
            return currentProfile.value
        }

        guard let profile = strategy.profile(withId: id) else {
            assertionFailure("Profile in headers yet not found in persistent store")
            return nil
        }
        guard availabilityFilter?(profile.header) ?? true else {
            pp_log.warning("Profile \(profile.logDescription) not available due to filter")
            return nil
        }
        guard !profile.vpnProtocols.isEmpty else {
            assertionFailure("Ditching profile, no OpenVPN/WireGuard settings found")
            return nil
        }

        pp_log.debug("Profile \(profile.logDescription) found")
        keychain.debugAllPasswords(matching: id, context: appGroup)

        return profile
    }

    public func saveProfile(_ profile: Profile, isActive: Bool?) {
        guard !profile.isPlaceholder else {
            assertionFailure("Placeholder")
            return
        }

        pp_log.info("Writing profile \(profile.logDescription) to persistent store")
        strategy.saveProfile(profile)

        if let isActive = isActive {
            if isActive {
                pp_log.info("\tActivating profile...")
                activeProfileId = profile.id
            } else if activeProfileId == profile.id {
                pp_log.info("\tDeactivating profile...")
                activeProfileId = nil
            }
        }

        // IMPORTANT: refresh live copy if just saved
        if isCurrentProfile(profile.id) {
            pp_log.info("Saved profile is also current profile, updating...")
            currentProfile.value = profile
        }
    }
    
    public func removeProfiles(withIds ids: [UUID]) {
        pp_log.info("Deleting profiles with ids \(ids)")

        pp_log.info("\tDeleting passwords from keychain...")
        for id in ids {
            keychain.removeAllPasswords(matching: id, context: appGroup)
        }

        pp_log.info("\tDeleting from persistent store...")
        strategy.removeProfiles(withIds: ids)
    }
    
    @available(*, deprecated, message: "only use for testing")
    public func removeAllProfiles() {
        let ids = Array(allHeaders.keys)
        removeProfiles(withIds: ids)
    }

    public func persist() {
        pp_log.info("Persisting profiles")
        saveCurrentProfile()
    }
}

// MARK: Observation

extension ProfileManager {
    public func loadCurrentProfile(withId id: UUID) throws -> LoadResult {
        if isExistingProfile(withId: currentProfile.value.id) {
            pp_log.info("Committing changes of former current profile \(currentProfile.value.logDescription)")
            saveCurrentProfile()
        }
        do {
            let result = try loadProfile(withId: id)
            pp_log.info("Current profile: \(result.profile.logDescription)")
            currentProfile.value = result.profile
            return result
        } catch {
            currentProfile.value = .placeholder
            throw error
        }
    }
    
    public func isCurrentProfileActive() -> Bool {
        currentProfile.value.id == activeProfileId
    }
    
    public func isCurrentProfile(_ id: UUID) -> Bool {
        id == currentProfile.value.id
    }

    public func activateCurrentProfile() {
        activateProfile(currentProfile.value)
    }
    
    public func saveCurrentProfile() {
        guard !currentProfile.value.isPlaceholder else {
            pp_log.debug("No current profile or deleted, not persisting")
            return
        }
        saveProfile(
            currentProfile.value,
            isActive: currentProfile.value.id == activeProfileId
        )
    }
}

extension ProfileManager {
    private func observeUpdates() {
        strategy.willUpdateProfiles()
            .dropFirst()
            .sink {
                self.willUpdateProfiles($0)
            }.store(in: &cancellables)

        currentProfile.$value
            .dropFirst()
            .sink {
                self.willUpdateCurrentProfile($0)
            }.store(in: &cancellables)
    }
    
    private func willUpdateProfiles(_ newHeaders: [UUID: Profile.Header]) {
        pp_log.debug("Profiles updated: \(newHeaders)")
        defer {
            objectWillChange.send()
        }
        
        // IMPORTANT: invalidate current profile if deleted
        if !currentProfile.value.isPlaceholder && !newHeaders.keys.contains(currentProfile.value.id) {
            pp_log.info("\tCurrent profile deleted, invalidating...")
            if isCurrentProfileActive() {
                pp_log.info("\tCurrent profile was also active, deactivating...")
                activeProfileId = nil
            }
            currentProfile.value = .placeholder
        }

        let newProfile = strategy.profile(withId: currentProfile.value.id)
        if let newProfile = newProfile, newProfile != currentProfile.value {
            pp_log.info("Current profile remotely updated")
            currentProfile.value = newProfile
        }

        // IMPORTANT: defer task to avoid recursive saves
        // FIXME: Core Data, not sure about this workaround
        Task {
            fixDuplicateNames(in: newHeaders)
        }
    }
    
    private func willUpdateCurrentProfile(_ newProfile: Profile) {
        pp_log.debug("Current profile updated: \(newProfile.logDescription)")
        // observe current profile explicitly (no objectWillChange)
        
        willUpdateCurrentProfile.send(newProfile)
    }
    
    private func fixDuplicateNames(in newHeaders: [UUID: Profile.Header]) {
        var allNames = newHeaders.values.map(\.name)
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
            let headers = newHeaders.values.filter {
                $0.name == name
            }
            guard headers.count > 1 else {
                assertionFailure("Name '\(name)' marked as duplicate but headers.count not > 1")
                return
            }

//            headers.removeFirst()
            headers.forEach { dupHeader in
                let uniqueHeader = dupHeader.renamedUniquely()
                pp_log.debug("Renaming duplicate profile \(dupHeader.logDescription) to \(uniqueHeader.logDescription)")
                guard var uniqueProfile = profile(withId: uniqueHeader.id) else {
                    pp_log.warning("Skipping profile \(dupHeader.logDescription) renaming, not found")
                    return
                }
                uniqueProfile.header = uniqueHeader
                renamedProfiles.append(uniqueProfile)
            }
        }
        if !renamedProfiles.isEmpty {
            strategy.saveProfiles(renamedProfiles)
            pp_log.debug("Duplicates successfully renamed!")
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
            throw PassepartoutError.missingProfile
        }
    }
}
