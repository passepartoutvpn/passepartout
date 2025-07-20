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

public protocol ConfigManagerStrategy {
    // flag -> deployment (0-100)
    func flags() async throws -> [ConfigFlag: Int]
}

@MainActor
public final class ConfigManager: ObservableObject {
    private let strategy: ConfigManagerStrategy?

    @Published
    public private(set) var flags: Set<ConfigFlag>

    public init() {
        strategy = nil
        flags = []
    }

    public init(strategy: ConfigManagerStrategy) {
        self.strategy = strategy
        flags = []
    }

    // TODO: #1447, handle 0-100 deployment values with local random value
    public func refreshFlags() async {
        guard let strategy else {
            return
        }
        do {
            pp_log_g(.app, .debug, "Config: refreshing flags...")
            let deployment = try await strategy.flags()
            let active = deployment.filter {
                $0.value == 100
            }
            let newFlags = Set(active.map(\.key))
            guard newFlags != flags else {
                pp_log_g(.app, .debug, "Config: flags unchanged")
                return
            }
            flags = newFlags
            pp_log_g(.app, .info, "Config: \(newFlags)")
        } catch {
            pp_log_g(.app, .error, "Unable to refresh config flags: \(error)")
        }
    }
}
