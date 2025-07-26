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

    case skipsPurchases

    case usesModernCrypto

    public var key: String {
        "App.\(rawValue)"
    }
}

public struct AppPreferenceValues: Codable, Sendable {
    public var dnsFallsBack = true

    public var lastCheckedVersionDate: TimeInterval?

    public var lastCheckedVersion: String?

    public var lastUsedProfileId: Profile.ID?

    public var logsPrivateData = false

    public var skipsPurchases = false

    public var usesModernCrypto = false

    public init() {
    }
}
