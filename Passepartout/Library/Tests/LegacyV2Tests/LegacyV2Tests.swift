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
import XCTest

final class LegacyV2Tests: XCTestCase {
    func test_givenStore_whenFetch_thenReturnsProfilesV2() async throws {
        let sut = newStore()

        let profilesV2 = try await sut.fetchProfilesV2()
        XCTAssertEqual(profilesV2.count, 7)
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

        XCTAssertEqual(migratable.count, 7)
        XCTAssertEqual(Set(migratable.map(\.id)), Set(expectedIDs.compactMap(UUID.init(uuidString:))))
        XCTAssertEqual(Set(migratable.map(\.name)), Set(expectedNames))
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
