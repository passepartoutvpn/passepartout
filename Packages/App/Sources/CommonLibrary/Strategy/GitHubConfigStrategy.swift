// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation
import GenericJSON

@MainActor
public final class GitHubConfigStrategy: ConfigManagerStrategy {
    private let url: URL

    private let ttl: TimeInterval

    private var lastUpdated: Date

    public init(url: URL, ttl: TimeInterval) {
        self.url = url
        self.ttl = ttl
        lastUpdated = .distantPast
    }

    public func bundle() async throws -> ConfigBundle {
        if lastUpdated > .distantPast {
            let elapsed = -lastUpdated.timeIntervalSinceNow
            guard elapsed >= ttl else {
                pp_log_g(.app, .debug, "Config (GitHub): elapsed \(elapsed) < \(ttl)")
                throw AppError.rateLimit
            }
        }
        pp_log_g(.app, .debug, "Config (GitHub): fetching bundle from \(url)")
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringCacheData
        let result = try await URLSession.shared.data(for: request)
        lastUpdated = Date()
        return try JSONDecoder().decode(ConfigBundle.self, from: result.0)
    }
}
