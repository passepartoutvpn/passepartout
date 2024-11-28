//
//  ProfileImporterTests.swift
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

@testable import AppUIMain
import Combine
import CommonLibrary
import Foundation
import PassepartoutKit
import XCTest

final class ProfileImporterTests: XCTestCase {
    private let registry = Registry(
        allHandlers: [SomeModule.moduleHandler],
        allImplementations: [SomeModule.Implementation()]
    )

    private var subscriptions: Set<AnyCancellable> = []
}

@MainActor
extension ProfileImporterTests {
    func test_givenNoURLs_whenImport_thenNothingIsImported() async throws {
        let sut = ProfileImporter()
        let profileManager = ProfileManager(profiles: [])

        try await sut.tryImport(urls: [], profileManager: profileManager, registry: registry)
        XCTAssertEqual(sut.nextURL, nil)
        XCTAssertTrue(profileManager.previews.isEmpty)
    }

    func test_givenURL_whenImport_thenOneProfileIsImported() async throws {
        let sut = ProfileImporter()
        let profileManager = ProfileManager(profiles: [])
        let url = URL(string: "file:///filename.txt")!

        let exp = expectation(description: "Save")
        profileManager
            .didChange
            .receive(on: ImmediateScheduler.shared)
            .sink {
                switch $0 {
                case .save(let profile):
                    XCTAssertEqual(profile.modules.count, 2)
                    XCTAssertTrue(profile.modules.first is SomeModule)
                    XCTAssertTrue(profile.modules.last is OnDemandModule)
                    exp.fulfill()

                default:
                    break
                }
            }
            .store(in: &subscriptions)

        try await sut.tryImport(
            urls: [url],
            profileManager: profileManager,
            registry: registry
        )
        XCTAssertEqual(sut.nextURL, nil)

        await fulfillment(of: [exp])
    }

    func test_givenURLRequiringPassphrase_whenImportWithPassphrase_thenProfileIsImported() async throws {
        let sut = ProfileImporter()
        let profileManager = ProfileManager(profiles: [])
        let url = URL(string: "file:///filename.encrypted")!

        let exp = expectation(description: "Save")
        profileManager
            .didChange
            .receive(on: ImmediateScheduler.shared)
            .sink {
                switch $0 {
                case .save(let profile):
                    XCTAssertEqual(profile.modules.count, 2)
                    XCTAssertTrue(profile.modules.first is SomeModule)
                    XCTAssertTrue(profile.modules.last is OnDemandModule)
                    exp.fulfill()

                default:
                    break
                }
            }
            .store(in: &subscriptions)

        try await sut.tryImport(
            urls: [url],
            profileManager: profileManager,
            registry: registry
        )
        XCTAssertEqual(sut.nextURL, url)

        sut.currentPassphrase = "passphrase"
        try await sut.reImport(url: url, profileManager: profileManager, registry: registry)
        XCTAssertEqual(sut.nextURL, nil)

        await fulfillment(of: [exp])
    }

    func test_givenURLsRequiringPassphrase_whenImport_thenURLsArePending() async throws {
        let sut = ProfileImporter()
        let profileManager = ProfileManager(profiles: [])
        let url = URL(string: "file:///filename.encrypted")!

        try await sut.tryImport(
            urls: [url, url, url],
            profileManager: profileManager,
            registry: registry
        )
        XCTAssertEqual(sut.nextURL, url)
        XCTAssertEqual(sut.urlsRequiringPassphrase.count, 3)
    }
}

private struct SomeModule: Module {
    struct Implementation: ModuleImplementation, ModuleImporter {
        var moduleHandlerId: ModuleHandler.ID {
            moduleHandler.id
        }

        func module(fromURL url: URL, object: Any?) throws -> Module {
            if url.absoluteString.hasSuffix(".encrypted") {
                guard let passphrase = object as? String else {
                    throw PassepartoutError(.OpenVPN.passphraseRequired)
                }
                guard passphrase == "passphrase" else {
                    throw PassepartoutError(.crypto)
                }
            }
            return SomeModule()
        }
    }
}
