// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

extension Strings.Unlocalized.Placeholders {
    public static func ipDestination(forFamily family: Address.Family) -> String {
        switch family {
        case .v4:
            return "192.168.15.0/24"
        case .v6:
            return "fdbd:dcf8:d811:af73::/64"
        }
    }

    public static func ipAddress(forFamily family: Address.Family) -> String {
        switch family {
        case .v4:
            return "192.168.15.1"
        case .v6:
            return "fdbd:dcf8:d811:af73::1"
        }
    }

    public static let proxyIPv4Address = ipAddress(forFamily: .v4)
}

extension Strings.Views.Profile.SendTv {
    public static var title_compound: String {
        title(Strings.Unlocalized.appleTV)
    }
}

extension Strings.Modules.General.Rows {
    public static var appletv_compound: String {
        appletv(Strings.Unlocalized.appleTV)
    }
}
