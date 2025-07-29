// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

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

    public func isActive(_ flag: ConfigFlag) -> Bool {
        bundle?.map[flag]?.rate == 100
    }

    public func data(for flag: ConfigFlag) -> JSON? {
        guard let bundle, let map = bundle.map[flag], map.rate == 100 else {
            return nil
        }
        return map.data
    }
}
