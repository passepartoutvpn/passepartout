//
//  LegacyV2Tests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/12/24.
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

import CommonUtils
import Foundation
@testable import LegacyV2
import PassepartoutKit
import XCTest

final class LegacyV2Tests: XCTestCase {
    func test_givenStore_whenFetchV2_thenReturnsProfilesV2() async throws {
        let sut = newStore()

        let profilesV2 = try await sut.fetchProfilesV2()
        XCTAssertEqual(profilesV2.count, 4)
        XCTAssertEqual(Set(profilesV2.map(\.header.name)), [
            "Hide.me",
            "ProtonVPN",
            "TorGuard",
            "Windscribe"
        ])
    }

    func test_givenStore_whenFetch_thenReturnsMigratableProfiles() async throws {
        let sut = newStore()

        let migratable = try await sut.migratableProfiles()
        let expectedIDs = [
            "38208B87-0545-4B11-A762-D04ED7CB904F",
            "981E7CBD-7733-4CF3-9A51-2777614ED5D4",
            "8A568345-85C4-44C1-A9C4-612E8B07ADC5",
            "5D108793-7F62-4B4C-B194-0A7204C02E99"
        ]
        let expectedNames = [
            "Hide.me",
            "ProtonVPN",
            "TorGuard",
            "Windscribe"
        ]

        XCTAssertEqual(migratable.count, 4)
        XCTAssertEqual(Set(migratable.map(\.id)), Set(expectedIDs.compactMap(UUID.init(uuidString:))))
        XCTAssertEqual(Set(migratable.map(\.name)), Set(expectedNames))
    }

    func test_givenStore_whenMigrateHideMe_thenIsExpected() async throws {
        let sut = newStore()

        let id = try XCTUnwrap(UUID(uuidString: "8A568345-85C4-44C1-A9C4-612E8B07ADC5"))
        let migrated = try await sut.fetchProfiles(selection: [id])

        XCTAssertEqual(migrated.count, 1)
        let profile = try XCTUnwrap(migrated.first)
        XCTAssertEqual(profile.id, id)
        XCTAssertEqual(profile.name, "Hide.me")
        XCTAssertEqual(profile.attributes.lastUpdate, Date(timeIntervalSinceReferenceDate: 673117681.24825))

        XCTAssertEqual(profile.modules.count, 3)

        let onDemand = try XCTUnwrap(profile.firstModule(ofType: OnDemandModule.self))
        XCTAssertTrue(onDemand.isEnabled)
        XCTAssertEqual(onDemand.policy, .excluding)
        XCTAssertEqual(onDemand.withSSIDs, [
            "Safe Wi-Fi": true,
            "Friend's House": false
        ])
        XCTAssertTrue(onDemand.withOtherNetworks.isEmpty)

        let openVPN = try XCTUnwrap(profile.firstModule(ofType: OpenVPNModule.self))
        XCTAssertEqual(openVPN.credentials?.username, "foo")
        XCTAssertEqual(openVPN.credentials?.password, "bar")

        let dns = try XCTUnwrap(profile.firstModule(ofType: DNSModule.self))
        let dohURL = try XCTUnwrap(URL(string: "https://1.1.1.1/dns-query"))
        XCTAssertEqual(dns.protocolType, .https(url: dohURL))
        XCTAssertEqual(dns.servers, [
            Address(rawValue: "1.1.1.1"),
            Address(rawValue: "1.0.0.1")
        ])
    }

    func test_givenStore_whenMigrateProtonVPN_thenIsExpected() async throws {
        let sut = newStore()

        let id = try XCTUnwrap(UUID(uuidString: "981E7CBD-7733-4CF3-9A51-2777614ED5D4"))
        let migrated = try await sut.fetchProfiles(selection: [id])

        XCTAssertEqual(migrated.count, 1)
        let profile = try XCTUnwrap(migrated.first)
        XCTAssertEqual(profile.id, id)
        XCTAssertEqual(profile.name, "ProtonVPN")
        XCTAssertEqual(profile.attributes.lastUpdate, Date(timeIntervalSinceReferenceDate: 724509584.854822))

        XCTAssertEqual(profile.modules.count, 2)

        let onDemand = try XCTUnwrap(profile.firstModule(ofType: OnDemandModule.self))
        XCTAssertTrue(onDemand.isEnabled)
        XCTAssertEqual(onDemand.policy, .excluding)
        XCTAssertTrue(onDemand.withSSIDs.isEmpty)
        XCTAssertTrue(onDemand.withOtherNetworks.isEmpty)

        let openVPN = try XCTUnwrap(profile.firstModule(ofType: OpenVPNModule.self))
        XCTAssertEqual(openVPN.credentials?.username, "foo")
        XCTAssertEqual(openVPN.credentials?.password, "bar")
    }
}

private extension LegacyV2Tests {
    func newStore() -> LegacyV2 {
        guard let baseURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            fatalError()
        }
        return LegacyV2(
            coreDataLogger: nil,
            profilesContainerName: "Profiles",
            baseURL: baseURL,
            cloudKitIdentifier: nil
        )
    }
}
