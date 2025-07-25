//
//  AppPreference.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/11/24.
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
