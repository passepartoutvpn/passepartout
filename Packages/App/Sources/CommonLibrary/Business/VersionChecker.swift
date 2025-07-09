//
//  VersionChecker.swift
//  Partout
//
//  Created by Davide De Rosa on 7/8/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

@MainActor
public final class VersionChecker: ObservableObject {
    private let kvManager: KeyValueManager

    private let strategy: VersionCheckerStrategy

    private let currentVersion: SemanticVersion

    private let downloadURL: URL

    public init(
        kvManager: KeyValueManager,
        strategy: VersionCheckerStrategy,
        currentVersion: String,
        downloadURL: URL
    ) {
        guard let semCurrent = SemanticVersion(currentVersion) else {
            preconditionFailure("Unparsable current version: \(currentVersion)")
        }
        self.kvManager = kvManager
        self.strategy = strategy
        self.currentVersion = semCurrent
        self.downloadURL = downloadURL
    }

    public var latestDownloadURL: URL? {
        guard let latestVersionDescription = kvManager.string(forKey: AppPreference.lastCheckedVersion.key),
              let latestVersion = SemanticVersion(latestVersionDescription) else {
            return nil
        }
        return latestVersion > currentVersion ? downloadURL : nil
    }

    public func checkLatest() async throws -> URL? {
        let latestVersion = try await strategy.latestVersion()
        kvManager.set(latestVersion.description, forKey: AppPreference.lastCheckedVersion.key)
        pp_log_g(.app, .info, "GitHub: \(latestVersion) > \(currentVersion) = \(latestVersion > currentVersion)")
        return latestDownloadURL
    }
}
