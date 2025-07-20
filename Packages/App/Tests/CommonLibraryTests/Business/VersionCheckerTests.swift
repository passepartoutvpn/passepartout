//
//  VersionCheckerTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/9/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import Foundation
import Testing

@MainActor
struct VersionCheckerTests {
    let downloadURL = URL(string: "http://")!

    @Test
    func detectUpdate() async throws {
        let kv = KeyValueManager()
        let sut = VersionChecker(
            kvManager: kv,
            strategy: MockStrategy(),
            currentVersion: "1.2.3",
            downloadURL: downloadURL
        )
        #expect(sut.latestRelease == nil)
        try await sut.checkLatestRelease()
        let latest = try #require(sut.latestRelease)
        #expect(latest.url == downloadURL)
        #expect(latest == sut.latestRelease)
        #expect(kv.string(forKey: AppPreference.lastCheckedVersion.key) == "4.10.20")
    }

    @Test
    func ignoreUpdateIfUpToDate() async throws {
        let kv = KeyValueManager()
        let sut = VersionChecker(
            kvManager: kv,
            strategy: MockStrategy(),
            currentVersion: "5.0.0",
            downloadURL: downloadURL
        )
        #expect(sut.latestRelease == nil)
        try await sut.checkLatestRelease()
        let latest = sut.latestRelease
        #expect(latest == nil)
        #expect(sut.latestRelease == nil)
    }

    @Test
    func triggerRateLimitOnMultipleChecks() async throws {
        let kv = KeyValueManager()
        let strategy = MockStrategy()
        let sut = VersionChecker(
            kvManager: kv,
            strategy: strategy,
            currentVersion: "5.0.0",
            downloadURL: downloadURL
        )
        #expect(sut.latestRelease == nil)

        var lastChecked = kv.double(forKey: AppPreference.lastCheckedVersionDate.key)
        #expect(lastChecked == 0.0)

        _ = try await sut.checkLatestRelease()
        lastChecked = kv.double(forKey: AppPreference.lastCheckedVersionDate.key)
        #expect(lastChecked > 0.0)
        #expect(!strategy.didHitRateLimit)

        _ = try await sut.checkLatestRelease()
        #expect(strategy.didHitRateLimit)
    }
}

private final class MockStrategy: VersionCheckerStrategy {

    // only allow once
    var didHitRateLimit = false

    func latestVersion(since: Date) async throws -> SemanticVersion {
        if since > .distantPast {
            didHitRateLimit = true
        }
        return SemanticVersion("4.10.20")!
    }
}
