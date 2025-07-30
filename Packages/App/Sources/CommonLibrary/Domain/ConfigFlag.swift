// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

public enum ConfigFlag: String, RawRepresentable, Codable, Sendable {
    case appNotWorking
    case newPaywall
    case sendToTV
}

extension ConfigFlag: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
