//
//  BundleConfiguration+AppGroup.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/4/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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
import PassepartoutKit

// WARNING: beware of Constants.shared dependency

extension BundleConfiguration {
    public static var urlForAppLog: URL {
        cachesURL.appending(path: Constants.shared.log.appPath)
    }

    public static var urlForTunnelLog: URL {
        cachesURL.appending(path: Constants.shared.log.tunnelPath)
    }

    public static var urlForBetaReceipt: URL {
        cachesURL.appending(path: Constants.shared.tunnel.betaReceiptPath)
    }
}

private extension BundleConfiguration {
    static var cachesURL: URL {
        let groupId = mainString(for: .groupId)
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId) else {
            pp_log(.app, .error, "Unable to access App Group container")
            return FileManager.default.temporaryDirectory
        }
        return url.appending(components: "Library", "Caches")
    }
}
