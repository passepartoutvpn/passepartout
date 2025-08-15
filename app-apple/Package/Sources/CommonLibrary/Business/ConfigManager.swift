// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

public protocol ConfigManagerStrategy {
    func bundle() async throws -> ConfigBundle
}

@MainActor
public final class ConfigManager: ObservableObject {
    private let strategy: ConfigManagerStrategy?

    private let buildNumber: Int

    @Published
    private var bundle: ConfigBundle?

    private var isPending = false

    public init() {
        strategy = nil
        buildNumber = .max
    }

    public init(strategy: ConfigManagerStrategy, buildNumber: Int) {
        self.strategy = strategy
        self.buildNumber = buildNumber
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
        activeMap(for: flag) != nil
    }

    public func data(for flag: ConfigFlag) -> JSON? {
        activeMap(for: flag)?.data
    }
}

private extension ConfigManager {
    func activeMap(for flag: ConfigFlag) -> ConfigBundle.Config? {
        guard let map = bundle?.map[flag] else {
            return nil
        }
        if let minBuild = map.minBuild {
            guard buildNumber >= minBuild else {
                return nil
            }
        }
        return map
    }
}
