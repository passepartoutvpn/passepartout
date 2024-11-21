//
//  ProfileManagerTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/12/24.
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
@testable import CommonLibrary
import Foundation
import PassepartoutKit
import XCTest

@MainActor
final class ProfileManagerTests: XCTestCase {
    private let timeout = 1.0

    private var subscriptions: Set<AnyCancellable> = []
}

extension ProfileManagerTests {
}

// MARK: - View

extension ProfileManagerTests {
    func test_givenStatic_whenNotReady_thenHasProfiles() {
        let profile = newProfile()
        let sut = ProfileManager(profiles: [profile])
        XCTAssertFalse(sut.isReady)
        XCTAssertFalse(sut.hasProfiles)
        XCTAssertTrue(sut.headers.isEmpty)
    }

    func test_givenRepository_whenNotReady_thenHasNoProfiles() {
        let repository = InMemoryProfileRepository(profiles: [])
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil)
        XCTAssertFalse(sut.isReady)
        XCTAssertFalse(sut.hasProfiles)
        XCTAssertTrue(sut.headers.isEmpty)
    }

    func test_givenRepository_whenReady_thenHasProfiles() async throws {
        let profile = newProfile()
        let repository = InMemoryProfileRepository(profiles: [profile])
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)
        XCTAssertTrue(sut.hasProfiles)
        XCTAssertEqual(sut.headers.count, 1)
        XCTAssertEqual(sut.profile(withId: profile.id), profile)
    }

    func test_givenRepository_whenSearch_thenIsSearching() async throws {
        let profile1 = newProfile("foo")
        let profile2 = newProfile("bar")
        let repository = InMemoryProfileRepository(profiles: [profile1, profile2])
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)
        XCTAssertTrue(sut.hasProfiles)
        XCTAssertEqual(sut.headers.count, 2)

        try await wait(sut) {
            $0.search(byName: "ar")
        } until: {
            $0.headers.count == 1
        }
        XCTAssertTrue(sut.isSearching)
        let found = try XCTUnwrap(sut.headers.last)
        XCTAssertEqual(found.id, profile2.id)
    }

    func test_givenRepositoryAndProcessor_whenReady_thenHasInvokedProcessor() async throws {
        let profile = newProfile()
        let repository = InMemoryProfileRepository(profiles: [profile])
        let processor = MockProfileProcessor()
        processor.requiredFeatures = [.appleTV, .onDemand]
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil, processor: processor)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)

        XCTAssertEqual(processor.isIncludedCount, 1)
        XCTAssertEqual(processor.willRebuildCount, 0)
        XCTAssertEqual(processor.verifyCount, 1)
        XCTAssertEqual(sut.requiredFeatures(forProfileWithId: profile.id), processor.requiredFeatures)
    }

    func test_givenRepositoryAndProcessor_whenIncludedProfiles_thenLoadsIncluded() async throws {
        let localProfiles = [
            newProfile("local1"),
            newProfile("local2"),
            newProfile("local3")
        ]
        let repository = InMemoryProfileRepository(profiles: localProfiles)
        let processor = MockProfileProcessor()
        processor.isIncludedBlock = {
            $0.name == "local2"
        }
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil, processor: processor)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)

        XCTAssertEqual(sut.headers.count, 1)
        XCTAssertEqual(sut.headers.first?.name, "local2")
    }

    func test_givenRepositoryAndProcessor_whenRequiredFeaturesChange_thenMustReload() async throws {
        let profile = newProfile()
        let repository = InMemoryProfileRepository(profiles: [profile])
        let processor = MockProfileProcessor()
        processor.requiredFeatures = [.appleTV, .onDemand]
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil, processor: processor)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)

        XCTAssertEqual(sut.requiredFeatures(forProfileWithId: profile.id), processor.requiredFeatures)
        processor.requiredFeatures = [.interactiveLogin]
        XCTAssertNotEqual(sut.requiredFeatures(forProfileWithId: profile.id), processor.requiredFeatures)
        sut.reloadRequiredFeatures()
        XCTAssertEqual(sut.requiredFeatures(forProfileWithId: profile.id), processor.requiredFeatures)

        processor.requiredFeatures = nil
        XCTAssertNotNil(sut.requiredFeatures(forProfileWithId: profile.id))
        sut.reloadRequiredFeatures()
        XCTAssertNil(sut.requiredFeatures(forProfileWithId: profile.id))
        processor.requiredFeatures = []
        sut.reloadRequiredFeatures()
        XCTAssertNil(sut.requiredFeatures(forProfileWithId: profile.id))
    }
}

// MARK: - Edit

extension ProfileManagerTests {
    func test_givenRepository_whenSave_thenIsSaved() async throws {
        let repository = InMemoryProfileRepository(profiles: [])
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)
        XCTAssertFalse(sut.hasProfiles)

        let profile = newProfile()
        try await wait(sut) {
            try await $0.save(profile)
        } until: {
            $0.hasProfiles
        }
        XCTAssertEqual(sut.headers.count, 1)
        XCTAssertEqual(sut.profile(withId: profile.id), profile)
    }

    func test_givenRepository_whenSaveExisting_thenIsReplaced() async throws {
        let profile = newProfile("oldName")
        let repository = InMemoryProfileRepository(profiles: [profile])
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)
        XCTAssertEqual(sut.headers.first?.id, profile.id)

        var builder = profile.builder()
        builder.name = "newName"
        let renamedProfile = try builder.tryBuild()

        try await wait(sut) {
            try await $0.save(renamedProfile)
        } until: {
            $0.headers.first?.name == renamedProfile.name
        }
    }

    func test_givenRepositoryAndProcessor_whenSave_thenProcessorIsNotInvoked() async throws {
        let repository = InMemoryProfileRepository(profiles: [])
        let processor = MockProfileProcessor()
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil, processor: processor)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)
        XCTAssertFalse(sut.hasProfiles)

        let profile = newProfile()
        try await sut.save(profile)
        XCTAssertEqual(processor.willRebuildCount, 0)
        try await sut.save(profile, isLocal: false)
        XCTAssertEqual(processor.willRebuildCount, 0)
    }

    func test_givenRepositoryAndProcessor_whenSaveLocal_thenProcessorIsInvoked() async throws {
        let repository = InMemoryProfileRepository(profiles: [])
        let processor = MockProfileProcessor()
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil, processor: processor)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)
        XCTAssertFalse(sut.hasProfiles)

        let profile = newProfile()
        try await sut.save(profile, isLocal: true)
        XCTAssertEqual(processor.willRebuildCount, 1)
    }

    func test_givenRepository_whenSave_thenIsStoredToBackUpRepository() async throws {
        let repository = InMemoryProfileRepository(profiles: [])
        let backupRepository = InMemoryProfileRepository(profiles: [])
        let sut = ProfileManager(repository: repository, backupRepository: backupRepository, remoteRepositoryBlock: nil)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)
        XCTAssertFalse(sut.hasProfiles)

        let profile = newProfile()
        let exp = expectation(description: "Backup")
        backupRepository
            .profilesPublisher
            .sink {
                guard !$0.isEmpty else {
                    return
                }
                XCTAssertEqual($0.first, profile)
                exp.fulfill()
            }
            .store(in: &subscriptions)

        try await sut.save(profile)
        await fulfillment(of: [exp], timeout: timeout)
    }

    func test_givenRepository_whenRemove_thenIsRemoved() async throws {
        let profile = newProfile()
        let repository = InMemoryProfileRepository(profiles: [profile])
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil)

        try await waitForReady(sut)
        XCTAssertTrue(sut.isReady)
        XCTAssertTrue(sut.hasProfiles)

        try await wait(sut) {
            await $0.remove(withId: profile.id)
        } until: {
            !$0.hasProfiles
        }
        XCTAssertTrue(sut.headers.isEmpty)
    }
}

// MARK: - Remote/Attributes

extension ProfileManagerTests {
    func test_givenRemoteRepository_whenSaveRemotelyShared_thenIsStoredToRemoteRepository() async throws {
        let profile = newProfile()
        let repository = InMemoryProfileRepository()
        let remoteRepository = InMemoryProfileRepository()
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        })

        try await waitForReady(sut)

        let exp = expectation(description: "Remote")
        remoteRepository
            .profilesPublisher
            .sink {
                guard !$0.isEmpty else {
                    return
                }
                XCTAssertEqual($0.first, profile)
                exp.fulfill()
            }
            .store(in: &subscriptions)

        try await sut.save(profile, remotelyShared: true)
        await fulfillment(of: [exp], timeout: timeout)

        XCTAssertTrue(sut.isRemotelyShared(profileWithId: profile.id))
    }

    func test_givenRemoteRepository_whenSaveNotRemotelyShared_thenIsRemoveFromRemoteRepository() async throws {
        let profile = newProfile()
        let repository = InMemoryProfileRepository(profiles: [profile])
        let remoteRepository = InMemoryProfileRepository(profiles: [profile])
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        })

        try await waitForReady(sut)

        let exp = expectation(description: "Remote")
        remoteRepository
            .profilesPublisher
            .sink {
                guard $0.isEmpty else {
                    return
                }
                exp.fulfill()
            }
            .store(in: &subscriptions)

        try await sut.save(profile, remotelyShared: false)
        await fulfillment(of: [exp], timeout: timeout)

        XCTAssertFalse(sut.isRemotelyShared(profileWithId: profile.id))
    }
}

// MARK: - Shortcuts

extension ProfileManagerTests {
    func test_givenRepository_whenNew_thenReturnsProfileWithNewName() async throws {
        let profile = newProfile("example")
        let repository = InMemoryProfileRepository(profiles: [profile])
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil)

        try await waitForReady(sut)
        XCTAssertEqual(sut.headers.count, 1)

        let newProfile = sut.new(withName: profile.name)
        XCTAssertEqual(newProfile.name, "example.1")
    }

    func test_givenRepository_whenDuplicate_thenSavesProfileWithNewName() async throws {
        let profile = newProfile("example")
        let repository = InMemoryProfileRepository(profiles: [profile])
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: nil)

        try await waitForReady(sut)

        try await wait(sut) {
            try await $0.duplicate(profileWithId: profile.id)
        } until: {
            $0.headers.count == 2
        }

        try await wait(sut) {
            try await $0.duplicate(profileWithId: profile.id)
        } until: {
            $0.headers.count == 3
        }

        try await wait(sut) {
            try await $0.duplicate(profileWithId: profile.id)
        } until: {
            $0.headers.count == 4
        }

        XCTAssertEqual(sut.headers.map(\.name), [
            "example",
            "example.1",
            "example.2",
            "example.3"
        ])
    }
}

// MARK: - Observation

extension ProfileManagerTests {
    func test_givenRemoteRepository_whenUpdatesWithNewProfiles_thenImportsAll() async throws {
        let localProfiles = [
            newProfile("local1"),
            newProfile("local2")
        ]
        let remoteProfiles = [
            newProfile("remote1"),
            newProfile("remote2"),
            newProfile("remote3")
        ]
        let allProfiles = localProfiles + remoteProfiles
        let repository = InMemoryProfileRepository(profiles: localProfiles)
        let remoteRepository = InMemoryProfileRepository(profiles: remoteProfiles)
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        })

        try await wait(sut) {
            try await $0.observeLocal()
            try await $0.observeRemote(true)
        } until: {
            $0.headers.count == allProfiles.count
        }

        XCTAssertEqual(Set(sut.headers), Set(allProfiles.map { $0.header() }))
        localProfiles.forEach {
            XCTAssertFalse(sut.isRemotelyShared(profileWithId: $0.id))
        }
        remoteProfiles.forEach {
            XCTAssertTrue(sut.isRemotelyShared(profileWithId: $0.id))
        }
    }

    func test_givenRemoteRepository_whenUpdatesWithExistingProfiles_thenReplacesLocal() async throws {
        let l1 = UUID()
        let l2 = UUID()
        let l3 = UUID()
        let r3 = UUID()
        let localProfiles = [
            newProfile("local1", id: l1),
            newProfile("local2", id: l2),
            newProfile("local3", id: l3)
        ]
        let remoteProfiles = [
            newProfile("remote1", id: l1),
            newProfile("remote2", id: l2),
            newProfile("remote3", id: r3)
        ]
        let repository = InMemoryProfileRepository(profiles: localProfiles)
        let remoteRepository = InMemoryProfileRepository(profiles: remoteProfiles)
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        })

        try await wait(sut) {
            try await $0.observeLocal()
            try await $0.observeRemote(true)
        } until: {
            $0.headers.count == 4 // unique IDs
        }

        sut.headers.forEach {
            switch $0.id {
            case l1:
                XCTAssertEqual($0.name, "remote1")
                XCTAssertTrue(sut.isRemotelyShared(profileWithId: $0.id))
            case l2:
                XCTAssertEqual($0.name, "remote2")
                XCTAssertTrue(sut.isRemotelyShared(profileWithId: $0.id))
            case l3:
                XCTAssertEqual($0.name, "local3")
                XCTAssertFalse(sut.isRemotelyShared(profileWithId: $0.id))
            case r3:
                XCTAssertEqual($0.name, "remote3")
                XCTAssertTrue(sut.isRemotelyShared(profileWithId: $0.id))
            default:
                XCTFail("Unknown profile: \($0.id)")
            }
        }
    }

    func test_givenRemoteRepository_whenUpdatesWithNotIncludedProfiles_thenImportsNone() async throws {
        let localProfiles = [
            newProfile("local1"),
            newProfile("local2")
        ]
        let remoteProfiles = [
            newProfile("remote1"),
            newProfile("remote2"),
            newProfile("remote3")
        ]
        let allProfiles = localProfiles + remoteProfiles
        let repository = InMemoryProfileRepository(profiles: localProfiles)
        let remoteRepository = InMemoryProfileRepository(profiles: remoteProfiles)
        let processor = MockProfileProcessor()
        processor.isIncludedBlock = {
            !$0.name.hasPrefix("remote")
        }
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        }, processor: processor)

        var didImport = false
        observeRemoteImport(sut) {
            didImport = true
        }
        try await waitForReady(sut)
        try await wait(sut) { _ in
            //
        } until: { _ in
            didImport
        }

        XCTAssertEqual(processor.isIncludedCount, allProfiles.count)
        XCTAssertEqual(Set(sut.headers), Set(localProfiles.map { $0.header() }))
        localProfiles.forEach {
            XCTAssertFalse(sut.isRemotelyShared(profileWithId: $0.id))
        }
        remoteProfiles.forEach {
            XCTAssertNil(sut.profile(withId: $0.id))
            XCTAssertTrue(sut.isRemotelyShared(profileWithId: $0.id))
        }
    }

    func test_givenRemoteRepository_whenUpdatesWithSameFingerprint_thenDoesNotImport() async throws {
        let l1 = UUID()
        let l2 = UUID()
        let fp1 = UUID()
        let localProfiles = [
            newProfile("local1", id: l1, fingerprint: fp1),
            newProfile("local2", id: l2, fingerprint: UUID())
        ]
        let remoteProfiles = [
            newProfile("remote1", id: l1, fingerprint: fp1),
            newProfile("remote2", id: l2, fingerprint: UUID())
        ]
        let repository = InMemoryProfileRepository(profiles: localProfiles)
        let remoteRepository = InMemoryProfileRepository(profiles: remoteProfiles)
        let processor = MockProfileProcessor()
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        }, processor: processor)

        var didImport = false
        observeRemoteImport(sut) {
            didImport = true
        }
        try await waitForReady(sut)
        try await wait(sut) { _ in
            //
        } until: { _ in
            didImport
        }

        try sut.headers.forEach {
            let profile = try XCTUnwrap(sut.profile(withId: $0.id))
            XCTAssertTrue(sut.isRemotelyShared(profileWithId: $0.id))
            switch $0.id {
            case l1:
                XCTAssertEqual(profile.name, "local1")
                XCTAssertEqual(profile.attributes.fingerprint, localProfiles[0].attributes.fingerprint)
            case l2:
                XCTAssertEqual(profile.name, "remote2")
                XCTAssertEqual(profile.attributes.fingerprint, remoteProfiles[1].attributes.fingerprint)
            default:
                XCTFail("Unknown profile: \($0.id)")
            }
        }
    }

    func test_givenRemoteRepository_whenUpdatesMultipleTimes_thenLatestImportWins() async throws {
        let localProfiles = [
            newProfile("local1"),
            newProfile("local2")
        ]
        let repository = InMemoryProfileRepository(profiles: localProfiles)
        let remoteRepository = InMemoryProfileRepository()
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        })

        try await wait(sut) {
            try await $0.observeLocal()
            try await $0.observeRemote(true)
        } until: {
            $0.headers.count == localProfiles.count
        }

        let r1 = UUID()
        let r2 = UUID()
        let r3 = UUID()
        let fp1 = UUID()
        let fp2 = UUID()
        let fp3 = UUID()

        try await wait(sut) { _ in
            remoteRepository.profiles = [
                newProfile("remote1", id: r1)
            ]
            remoteRepository.profiles = [
                newProfile("remote1", id: r1),
                newProfile("remote2", id: r2),
            ]
            remoteRepository.profiles = [
                newProfile("remote1", id: r1, fingerprint: fp1),
                newProfile("remote2", id: r2, fingerprint: fp2),
                newProfile("remote3", id: r3, fingerprint: fp3)
            ]
        } until: {
            $0.headers.count == 5
        }

        localProfiles.forEach {
            XCTAssertFalse(sut.isRemotelyShared(profileWithId: $0.id))
        }
        remoteRepository.profiles.forEach {
            XCTAssertTrue(sut.isRemotelyShared(profileWithId: $0.id))
            switch $0.id {
            case r1:
                XCTAssertEqual($0.attributes.fingerprint, fp1)
            case r2:
                XCTAssertEqual($0.attributes.fingerprint, fp2)
            case r3:
                XCTAssertEqual($0.attributes.fingerprint, fp3)
            default:
                XCTFail("Unknown profile: \($0.id)")
            }
        }
    }

    func test_givenRemoteRepository_whenRemoteIsDeleted_thenLocalIsRetained() async throws {
        let profile = newProfile()
        let localProfiles = [profile]
        let remoteProfiles = [profile]
        let repository = InMemoryProfileRepository(profiles: localProfiles)
        let remoteRepository = InMemoryProfileRepository(profiles: remoteProfiles)
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        })

        var didImport = false
        observeRemoteImport(sut) {
            didImport = true
        }
        try await wait(sut) {
            try await $0.observeLocal()
            try await $0.observeRemote(true)
        } until: {
            $0.headers.count == 1
        }
        try await wait(sut) { _ in
            remoteRepository.profiles = []
        } until: { _ in
            didImport
        }

        XCTAssertEqual(sut.headers.count, 1)
        XCTAssertEqual(sut.headers.first, profile.header())
    }

    func test_givenRemoteRepositoryAndMirroring_whenRemoteIsDeleted_thenLocalIsDeleted() async throws {
        let profile = newProfile()
        let localProfiles = [profile]
        let repository = InMemoryProfileRepository(profiles: localProfiles)
        let remoteRepository = InMemoryProfileRepository()
        let sut = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        }, mirrorsRemoteRepository: true)

        var didImport = false
        observeRemoteImport(sut) {
            didImport = true
        }
        try await wait(sut) {
            try await $0.observeLocal()
            try await $0.observeRemote(true)
        } until: {
            $0.headers.count == 1
        }
        try await wait(sut) { _ in
            remoteRepository.profiles = []
        } until: { _ in
            didImport
        }
        XCTAssertFalse(sut.hasProfiles)
    }
}

// MARK: -

private extension ProfileManagerTests {
    func newProfile(_ name: String = "", id: UUID? = nil, fingerprint: UUID? = nil) -> Profile {
        do {
            var builder = Profile.Builder(id: id ?? UUID())
            builder.name = name
            if let fingerprint {
                builder.attributes.fingerprint = fingerprint
            }
            return try builder.tryBuild()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func waitForReady(_ sut: ProfileManager, importingRemote: Bool = true) async throws {
        try await wait(sut) {
            try await $0.observeLocal()
            try await $0.observeRemote(importingRemote)
        } until: {
            $0.isReady
        }
    }

    func observeRemoteImport(_ sut: ProfileManager, block: @escaping () -> Void) {
        sut
            .didChange
            .sink {
                if case .stopRemoteImport = $0 {
                    block()
                }
            }
            .store(in: &subscriptions)
    }

    func wait(
        _ sut: ProfileManager,
        after action: (ProfileManager) async throws -> Void,
        until condition: @escaping (ProfileManager) -> Bool
    ) async throws {
        let exp = expectation(description: "Wait")
        var wasMet = false
        sut.objectWillChange
            .sink {
                guard !wasMet else {
                    return
                }
                if condition(sut) {
                    wasMet = true
                    exp.fulfill()
                }
            }
            .store(in: &subscriptions)

        try await action(sut)
        await fulfillment(of: [exp], timeout: timeout)
    }
}
