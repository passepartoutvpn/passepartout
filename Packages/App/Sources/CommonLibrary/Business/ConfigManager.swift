//
//  ConfigManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/20/25.
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

public protocol ConfigManagerStrategy {
    func bundle() async throws -> ConfigBundle
}

@MainActor
public final class ConfigManager: ObservableObject {
    private let strategy: ConfigManagerStrategy?

    @Published
    private var bundle: ConfigBundle?

    private var isPending = false

    public init() {
        strategy = nil
    }

    public init(strategy: ConfigManagerStrategy) {
        self.strategy = strategy
    }

    // TODO: #1447, handle 0-100 deployment values with local random value
    public func refreshBundle() async {
        guard let strategy else {
            return
        }
        guard !isPending else {
            return
        }
        isPending = true
        defer {
            isPending = false
        }
        do {
            pp_log_g(.app, .debug, "Config: refreshing bundle...")
            let newBundle = try await strategy.bundle()
            bundle = newBundle
            pp_log_g(.app, .info, "Config: active flags = \(newBundle.activeFlags)")
            pp_log_g(.app, .debug, "Config: \(newBundle)")
        } catch AppError.rateLimit {
            pp_log_g(.app, .debug, "Config: TTL")
        } catch {
            pp_log_g(.app, .error, "Unable to refresh config flags: \(error)")
        }
    }

    public func data(for flag: ConfigFlag) -> JSON? {
        guard let bundle, let map = bundle.map[flag], map.rate == 100 else {
            return nil
        }
        return map.data
    }
}
