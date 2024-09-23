//
//  ProfileEditorTests.swift
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

@testable import AppLibrary
import Combine
import Foundation
import PassepartoutKit
import XCTest

final class ProfileEditorTests: XCTestCase {
    private var subscriptions: Set<AnyCancellable> = []
}

@MainActor
extension ProfileEditorTests {

    // MARK: CRUD

    func test_givenModules_thenMatchesModules() {
        let sut = ProfileEditor(modules: [
            DNSModule.Builder(),
            IPModule.Builder()
        ])
        XCTAssertTrue(sut.name.isEmpty)
        XCTAssertTrue(sut.modules[0] is DNSModule.Builder)
        XCTAssertTrue(sut.modules[1] is IPModule.Builder)
    }

    func test_givenProfile_thenMatchesProfile() throws {
        let name = "foobar"
        let dns = try DNSModule.Builder().tryBuild()
        let ip = IPModule.Builder().tryBuild()
        let profile = try Profile.Builder(
            name: name,
            modules: [dns, ip],
            activeModulesIds: [dns.id]
        ).tryBuild()

        let sut = ProfileEditor(profile: profile)
        XCTAssertEqual(sut.name, name)
        XCTAssertTrue(sut.modules[0] is DNSModule.Builder)
        XCTAssertTrue(sut.modules[1] is IPModule.Builder)
        XCTAssertEqual(sut.activeModulesIds, [dns.id])
    }

    func test_givenProfileWithModules_thenExcludesModuleTypes() {
        let sut = ProfileEditor(modules: [
            DNSModule.Builder(),
            IPModule.Builder()
        ])
        let moduleTypes = sut.availableModuleTypes

        XCTAssertFalse(moduleTypes.contains(.dns))
        XCTAssertTrue(moduleTypes.contains(.httpProxy))
        XCTAssertFalse(moduleTypes.contains(.ip))
        XCTAssertTrue(moduleTypes.contains(.onDemand))

        // until editable
        XCTAssertFalse(moduleTypes.contains(.openVPN))
        XCTAssertFalse(moduleTypes.contains(.wireGuard))
    }

    func test_givenModules_thenReturnsModuleById() {
        let dns = DNSModule.Builder()
        let ip = IPModule.Builder()
        let sut = ProfileEditor(modules: [dns, ip])

        XCTAssertEqual(sut.modules[0].id, dns.id)
        XCTAssertEqual(sut.modules[1].id, ip.id)
        XCTAssertTrue(sut.module(withId: dns.id) is DNSModule.Builder)
        XCTAssertTrue(sut.module(withId: ip.id) is IPModule.Builder)
        XCTAssertNil(sut.module(withId: UUID()))
    }

    func test_givenModules_whenMove_thenMovesModules() {
        let dns = DNSModule.Builder()
        let ip = IPModule.Builder()
        let sut = ProfileEditor(modules: [dns, ip])

        sut.moveModules(from: IndexSet(integer: 0), to: 2)
        XCTAssertEqual(sut.modules[0].id, ip.id)
        XCTAssertEqual(sut.modules[1].id, dns.id)
    }

    func test_givenModules_whenRemove_thenRemovesModules() {
        let dns = DNSModule.Builder()
        let ip = IPModule.Builder()
        let sut = ProfileEditor(modules: [dns, ip])

        sut.removeModules(at: IndexSet(integer: 0))
        XCTAssertEqual(sut.modules.count, 1)
        XCTAssertEqual(sut.modules[0].id, ip.id)
        XCTAssertEqual(Set(sut.removedModules.keys), [dns.id])

        sut.removeModule(withId: dns.id)
        sut.removeModule(withId: ip.id)
        XCTAssertTrue(sut.modules.isEmpty)
        XCTAssertEqual(Set(sut.removedModules.keys), [dns.id, ip.id])
    }

    func test_givenModules_whenSaveNew_thenAppendsNew() {
        let dns = DNSModule.Builder()
        let ip = IPModule.Builder()
        let sut = ProfileEditor(modules: [dns, ip])

        sut.saveModule(ip, activating: false)
        XCTAssertTrue(sut.modules[1] is IPModule.Builder)
        XCTAssertEqual(sut.activeModulesIds, [dns.id])
    }

    func test_givenModules_whenSaveExisting_thenReplacesExisting() throws {
        var dns = DNSModule.Builder()
        let ip = IPModule.Builder()
        let sut = ProfileEditor(modules: [dns, ip])

        dns.protocolType = .tls
        sut.saveModule(dns, activating: false)
        XCTAssertEqual(sut.activeModulesIds, [dns.id])

        let newDNS = try XCTUnwrap(sut.modules[0] as? DNSModule.Builder)
        XCTAssertEqual(newDNS.protocolType, dns.protocolType)
    }

    func test_givenModules_whenSaveActivating_thenActivates() {
        let dns = DNSModule.Builder()
        let sut = ProfileEditor(modules: [])

        sut.saveModule(dns, activating: true)
        XCTAssertEqual(sut.activeModulesIds, [dns.id])
    }

    // MARK: - Active modules

    func test_givenModules_whenToggle_thenToggles() throws {
        let dns = DNSModule.Builder()
        let proxy = HTTPProxyModule.Builder()
        let sut = ProfileEditor(modules: [dns, proxy])

        XCTAssertEqual(sut.activeModulesIds, [dns.id, proxy.id])
        try sut.toggleModule(withId: dns.id)
        XCTAssertEqual(sut.activeModulesIds, [proxy.id])
        try sut.toggleModule(withId: dns.id)
        XCTAssertEqual(sut.activeModulesIds, [dns.id, proxy.id])
        try sut.toggleModule(withId: dns.id)
        try sut.toggleModule(withId: proxy.id)
        XCTAssertEqual(sut.activeModulesIds, [])
    }

    func test_givenModules_whenToggleConnection_thenExcludesOtherOne() throws {
        let ovpn = OpenVPNModule.Builder()
        let wg = WireGuardModule.Builder(configurationBuilder: .default)
        let sut = ProfileEditor(modules: [ovpn, wg])

        XCTAssertEqual(sut.activeModulesIds, [ovpn.id])
        try sut.toggleModule(withId: wg.id)
        XCTAssertEqual(sut.activeModulesIds, [wg.id])
    }

    func test_givenModulesWithoutConnection_whenToggleIP_thenFailsToToggle() throws {
        let ip = IPModule.Builder()
        let sut = ProfileEditor(modules: [ip])

        XCTAssertEqual(sut.activeModulesIds, [])
        XCTAssertThrowsError(try sut.toggleModule(withId: ip.id))
    }

    // MARK: Building

    func test_givenProfile_whenBuild_thenSucceeds() throws {
        let wg = WireGuardModule.Builder(configurationBuilder: .default)
        let sut = ProfileEditor(modules: [wg])
        sut.name = "hello"

        let profile = try sut.build()
        XCTAssertEqual(profile.name, "hello")
        XCTAssertTrue(profile.modules.first is WireGuardModule)
        XCTAssertEqual(profile.modules.first as? WireGuardModule, try wg.tryBuild())
        XCTAssertEqual(profile.activeModulesIds, [wg.id])
    }

    func test_givenProfile_whenBuildWithEmptyName_thenFails() async throws {
        let sut = ProfileEditor(modules: [])
        XCTAssertThrowsError(try sut.build())
    }

    func test_givenProfile_whenBuildWithMalformedModule_thenFails() async throws {
        let dns = DNSModule.Builder(protocolType: .https) // missing URL
        let sut = ProfileEditor(modules: [dns])
        XCTAssertThrowsError(try sut.build())
    }

    // MARK: Saving

    func test_givenProfileManager_whenSave_thenSavesProfileToManager() async throws {
        let name = "foobar"
        let dns = try DNSModule.Builder().tryBuild()
        let ip = IPModule.Builder().tryBuild()
        let profile = try Profile.Builder(
            name: name,
            modules: [dns, ip],
            activeModulesIds: [dns.id]
        ).tryBuild()

        let sut = ProfileEditor(profile: profile)
        let manager = ProfileManager(profiles: [])

        let exp = expectation(description: "Save")
        manager
            .didSave
            .sink {
                XCTAssertEqual($0, profile)
                exp.fulfill()
            }
            .store(in: &subscriptions)

        try await sut.save(to: manager)
        await fulfillment(of: [exp])
    }
}
