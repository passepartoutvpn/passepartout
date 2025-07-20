//
//  VersionChecker.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/8/25.
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

import Foundation

@MainActor
public final class VersionChecker: ObservableObject {
    public struct Release: Hashable, Sendable {
        public let version: SemanticVersion

        public let url: URL
    }

    private let kvManager: KeyValueManager

    private let strategy: VersionCheckerStrategy

    private let currentVersion: SemanticVersion

    private let downloadURL: URL

    private var isPending = false

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

    public var latestRelease: Release? {
        guard let latestVersionDescription = kvManager.string(forKey: AppPreference.lastCheckedVersion.key),
              let latestVersion = SemanticVersion(latestVersionDescription) else {
            return nil
        }
        return latestVersion > currentVersion ? Release(version: latestVersion, url: downloadURL) : nil
    }

    public func checkLatestRelease() async {
        guard !isPending else {
            return
        }
        isPending = true
        defer {
            isPending = false
        }
        let now = Date()
        do {
            let lastCheckedInterval = kvManager.double(forKey: AppPreference.lastCheckedVersionDate.key)
            let lastCheckedDate = lastCheckedInterval > 0.0 ? Date(timeIntervalSinceReferenceDate: lastCheckedInterval) : .distantPast

            pp_log_g(.app, .debug, "Version: checking for updates...")
            let fetchedLatestVersion = try await strategy.latestVersion(since: lastCheckedDate)
            kvManager.set(now.timeIntervalSinceReferenceDate, forKey: AppPreference.lastCheckedVersionDate.key)
            kvManager.set(fetchedLatestVersion.description, forKey: AppPreference.lastCheckedVersion.key)
            pp_log_g(.app, .info, "Version: \(fetchedLatestVersion) > \(currentVersion) = \(fetchedLatestVersion > currentVersion)")

            objectWillChange.send()

            if let latestRelease {
                pp_log_g(.app, .info, "Version: new version available at \(latestRelease.url)")
            } else {
                pp_log_g(.app, .debug, "Version: current is latest version")
            }
        } catch AppError.rateLimit {
            pp_log_g(.app, .debug, "Version: rate limit")
        } catch AppError.unexpectedResponse {
            // save the check date regardless because the service call succeeded
            kvManager.set(now.timeIntervalSinceReferenceDate, forKey: AppPreference.lastCheckedVersionDate.key)

            pp_log_g(.app, .error, "Unable to check version: \(AppError.unexpectedResponse)")
        } catch {
            pp_log_g(.app, .error, "Unable to check version: \(error)")
        }
    }
}

extension VersionChecker {
    private final class DummyStrategy: VersionCheckerStrategy {
        func latestVersion(since: Date) async throws -> SemanticVersion {
            SemanticVersion("255.255.255")!
        }
    }

    public convenience init(downloadURL: URL = URL(string: "http://")!) {
        self.init(
            kvManager: KeyValueManager(),
            strategy: DummyStrategy(),
            currentVersion: "0.0.0", // an update is always available
            downloadURL: downloadURL
        )
    }
}
