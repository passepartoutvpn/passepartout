//
//  Strings+UnlocalizedExtensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/13/25.
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
