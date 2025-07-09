//
//  GitHubReleaseStrategy.swift
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
public final class GitHubReleaseStrategy: VersionCheckerStrategy {
    private let releaseURL: URL

    private let rateLimit: TimeInterval

    private var lastCheckDate: Date?

    public init(releaseURL: URL, rateLimit: TimeInterval) {
        self.releaseURL = releaseURL
        self.rateLimit = rateLimit
    }

    public func latestVersion() async throws -> SemanticVersion {
        if let lastCheckDate {
            guard -lastCheckDate.timeIntervalSinceNow > rateLimit else {
                throw AppError.rateLimit
            }
        }

        var request = URLRequest(url: releaseURL)
        request.cachePolicy = .useProtocolCachePolicy
        let result = try await URLSession.shared.data(for: request)
        lastCheckDate = Date()

        let json = try JSONDecoder().decode(VersionJSON.self, from: result.0)
        let newVersion = json.name
        guard let semNew = SemanticVersion(newVersion) else {
            pp_log_g(.app, .error, "GitHub: unparsable release name '\(newVersion)'")
            throw AppError.unexpectedResponse
        }
        return semNew
    }
}

private struct VersionJSON: Decodable, Sendable {
    enum CodingKeys: String, CodingKey {
        case name

        case tagName = "tag_name"
    }

    let name: String

    let tagName: String
}
