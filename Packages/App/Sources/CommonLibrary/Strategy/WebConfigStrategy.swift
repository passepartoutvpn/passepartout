//
//  WebConfigStrategy.swift
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
import GenericJSON

@MainActor
public final class WebConfigStrategy: ConfigManagerStrategy {
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
                pp_log_g(.app, .debug, "Config: elapsed \(elapsed) < \(ttl)")
                throw AppError.rateLimit
            }
        }
        pp_log_g(.app, .debug, "Config: fetching bundle from \(url)")
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringCacheData
        let result = try await URLSession.shared.data(for: request)
        lastUpdated = Date()
        return try JSONDecoder().decode(ConfigBundle.self, from: result.0)
    }
}
