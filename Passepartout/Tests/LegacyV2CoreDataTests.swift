//
//  LegacyV2CoreDataTests.swift
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

final class LegacyV2CoreDataTests: XCTestCase {
    func test_givenStore_whenFetchV2_thenReturnsProfilesV2() async throws {
        let sut = newStore()

        let profilesV2 = try await sut.fetchProfilesV2()
        XCTAssertEqual(profilesV2.count, 6)
        XCTAssertEqual(Set(profilesV2.map(\.header.name)), [
            "Hide.me",
            "ProtonVPN",
            "TorGuard",
            "vps-ta-cert-cbc256-lzo",
            "vps-wg",
            "Windscribe"
        ])
    }

    func test_givenStore_whenFetch_thenReturnsMigratableProfiles() async throws {
        let sut = newStore()

        let migratable = try await sut.fetchMigratableProfiles()
        let expectedIDs = [
            "069F76BD-1F6B-425C-AD83-62477A8B6558",
            "239AD322-7440-4198-990A-D91379916FE2",
            "38208B87-0545-4B11-A762-D04ED7CB904F",
            "5D108793-7F62-4B4C-B194-0A7204C02E99",
            "8A568345-85C4-44C1-A9C4-612E8B07ADC5",
            "981E7CBD-7733-4CF3-9A51-2777614ED5D4"
        ]
        let expectedNames = [
            "Hide.me",
            "ProtonVPN",
            "TorGuard",
            "vps-ta-cert-cbc256-lzo",
            "vps-wg",
            "Windscribe"
        ]

        XCTAssertEqual(migratable.count, 6)
        XCTAssertEqual(Set(migratable.map(\.id)), Set(expectedIDs.compactMap(UUID.init(uuidString:))))
        XCTAssertEqual(Set(migratable.map(\.name)), Set(expectedNames))
    }

    func test_givenStore_whenMigrateHideMe_thenIsExpected() async throws {
        let sut = newStore()

        let id = try XCTUnwrap(UUID(uuidString: "8A568345-85C4-44C1-A9C4-612E8B07ADC5"))
        let result = try await sut.fetchProfiles(selection: [id])
        let migrated = result.migrated
        XCTAssertEqual(migrated.count, 1)
        XCTAssertTrue(result.failed.isEmpty)

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
        let result = try await sut.fetchProfiles(selection: [id])
        let migrated = result.migrated
        XCTAssertEqual(migrated.count, 1)
        XCTAssertTrue(result.failed.isEmpty)

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

    func test_givenStore_whenMigrateVPSOpenVPN_thenIsExpected() async throws {
        let sut = newStore()

        let id = try XCTUnwrap(UUID(uuidString: "239AD322-7440-4198-990A-D91379916FE2"))
        let result = try await sut.fetchProfiles(selection: [id])
        let migrated = result.migrated
        XCTAssertEqual(migrated.count, 1)
        XCTAssertTrue(result.failed.isEmpty)

        XCTAssertEqual(migrated.count, 1)
        let profile = try XCTUnwrap(migrated.first)
        XCTAssertEqual(profile.id, id)
        XCTAssertEqual(profile.name, "vps-ta-cert-cbc256-lzo")
        XCTAssertEqual(profile.attributes.lastUpdate, Date(timeIntervalSinceReferenceDate: 726164772.28976))

        XCTAssertEqual(profile.modules.count, 2)

        let onDemand = try XCTUnwrap(profile.firstModule(ofType: OnDemandModule.self))
        XCTAssertTrue(onDemand.isEnabled)
        XCTAssertEqual(onDemand.policy, .excluding)
        XCTAssertTrue(onDemand.withSSIDs.isEmpty)
        XCTAssertTrue(onDemand.withOtherNetworks.isEmpty)

        let openVPN = try XCTUnwrap(profile.firstModule(ofType: OpenVPNModule.self))
        XCTAssertNil(openVPN.credentials)
        let cfg = try XCTUnwrap(openVPN.configuration)
        XCTAssertEqual(cfg.remotes, [
            try .init("1.2.3.4", .init(.udp, 1198))
        ])
        XCTAssertEqual(cfg.authUserPass, false)
        XCTAssertEqual(cfg.cipher, .aes256cbc)
        XCTAssertEqual(cfg.digest, .sha256)
        XCTAssertEqual(cfg.keepAliveInterval, 25.0)
        XCTAssertEqual(cfg.checksEKU, true)
        XCTAssertEqual(cfg.tlsWrap?.strategy, .auth)
    }

    func test_givenStore_whenMigrateVPSWireGuard_thenIsExpected() async throws {
        let sut = newStore()

        let id = try XCTUnwrap(UUID(uuidString: "069F76BD-1F6B-425C-AD83-62477A8B6558"))
        let result = try await sut.fetchProfiles(selection: [id])
        let migrated = result.migrated
        XCTAssertEqual(migrated.count, 1)
        XCTAssertTrue(result.failed.isEmpty)

        XCTAssertEqual(migrated.count, 1)
        let profile = try XCTUnwrap(migrated.first)
        XCTAssertEqual(profile.id, id)
        XCTAssertEqual(profile.name, "vps-wg")
        XCTAssertEqual(profile.attributes.lastUpdate, Date(timeIntervalSinceReferenceDate: 727398252.46203))

        XCTAssertEqual(profile.modules.count, 2)

        let onDemand = try XCTUnwrap(profile.firstModule(ofType: OnDemandModule.self))
        XCTAssertFalse(onDemand.isEnabled)
        XCTAssertEqual(onDemand.policy, .including)
        XCTAssertTrue(onDemand.withSSIDs.isEmpty)
        XCTAssertTrue(onDemand.withOtherNetworks.isEmpty)

        let wireGuard = try XCTUnwrap(profile.firstModule(ofType: WireGuardModule.self))
        let cfg = try XCTUnwrap(wireGuard.configuration)
        XCTAssertEqual(cfg.interface.privateKey.rawValue, "6L8Cv9zpG8RTDDwvZMhv6OR3kGdd+yATuKnMQWVLT1Q=")
        XCTAssertEqual(cfg.interface.addresses, [
            try .init("4.5.6.7", 32)
        ])
        XCTAssertEqual(cfg.interface.dns?.servers, [
            try XCTUnwrap(Address(rawValue: "1.1.1.1"))
        ])
        XCTAssertNil(cfg.interface.mtu)
        XCTAssertEqual(cfg.peers.count, 1)
        let peer = try XCTUnwrap(cfg.peers.first)
        XCTAssertEqual(peer.publicKey.rawValue, "JZc2trzk1WZTOUTjag1lcUZ2ePpFQYSpU2d0wqAw6mU=")
        XCTAssertEqual(peer.endpoint?.rawValue, "8.8.8.8:55555")
        XCTAssertEqual(peer.allowedIPs, [
            try .init("0.0.0.0", 0)
        ])
    }
}

private extension LegacyV2CoreDataTests {
    func newStore() -> LegacyV2 {
        guard let baseURL = Bundle(for: LegacyV2CoreDataTests.self).resourceURL else {
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
