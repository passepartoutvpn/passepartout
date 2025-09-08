// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

public enum ConfigFlag: String, CaseIterable, RawRepresentable, Codable, Sendable {
    // These must be permanent
    case allowsRelaxedVerification
    case appNotWorking
    // These are temporary (older activations come last)
    case tvSendTo
    case wgCrossParser
    case wgCrossConnection
    case neSocket
    case tvWebImport            // 08/09
    case newPaywall             // 02/09
}

extension ConfigFlag: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
