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
        guard let baseURL = Bundle.module.url(forResource: "Resources", withExtension: nil) else {
            fatalError()
        }
        let legacy = LegacyV2(
            coreDataLogger: nil,
            profilesContainerName: "Profiles",
            baseURL: baseURL,
            cloudKitIdentifier: nil
        )
        let profilesV2 = try await legacy.fetchProfilesV2()
        XCTAssertEqual(profilesV2.count, 7)
        XCTAssertEqual(Set(profilesV2.map(\.header.name)), [
            "Hide.me",
            "ProtonVPN",
            "TorGuard",
            "Windscribe"
        ])
    }
}
