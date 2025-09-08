// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

public enum AppPreference: String, PreferenceProtocol {
    case deviceId

    case dnsFallsBack
//    case dnsFallbackServers

    case lastCheckedVersionDate

    case lastCheckedVersion

    case lastUsedProfileId

    case logsPrivateData

    case relaxedVerification

    case skipsPurchases

    case usesModernCrypto

    case configFlags // Not directly accessible

    public var key: String {
        "App.\(rawValue)"
    }
}

public struct AppPreferenceValues: Codable, Sendable {
    public var deviceId: String?

    public var dnsFallsBack = true

    public var lastCheckedVersionDate: TimeInterval?

    public var lastCheckedVersion: String?

    public var lastUsedProfileId: Profile.ID?

    public var logsPrivateData = false

    public var relaxedVerification = false

    public var skipsPurchases = false

    public var usesModernCrypto = false

    public var configFlagsData: Data? = nil

    public init() {
    }
}

extension AppPreferenceValues {
    public var configFlags: Set<ConfigFlag> {
        guard let data = configFlagsData else { return [] }
        do {
            return try JSONDecoder().decode(Set<ConfigFlag>.self, from: data)
        } catch {
            pp_log_g(.app, .error, "Unable to decode config flags: \(error)")
            return []
        }
    }
}
