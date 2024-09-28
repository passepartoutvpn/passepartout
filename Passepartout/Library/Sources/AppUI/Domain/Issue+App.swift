//
//  Issue+App.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/18/24.
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

import CommonLibrary
import Foundation
import PassepartoutKit

extension Issue {
    private static var tunnelLogURL: URL {
        Constants.shared.urlForTunnelLog(groupId: BundleConfiguration.mainString(for: .groupId))
    }

    static func with(versionString: String, purchasedProducts: Set<AppProduct>, tunnel: Tunnel) async -> Self {
        let appLog = CommonLibrary.currentLog(parameters: Constants.shared.log)
            .joined(separator: "\n")
            .data(using: .utf8)

        let tunnelLog: Data?

        // live tunnel log
        if await tunnel.status != .inactive {
            tunnelLog = await tunnel.currentLog(parameters: Constants.shared.log)
                .joined(separator: "\n")
                .data(using: .utf8)
        }
        // latest persisted tunnel log
        else if let latestTunnelEntry = CommonLibrary.availableLogs(at: tunnelLogURL)
            .max(by: { $0.key < $1.key }) {

            tunnelLog = try? Data(contentsOf: latestTunnelEntry.value)
        }
        // nothing
        else {
            tunnelLog = nil
        }

        return Issue(
            appLine: "\(Strings.Unlocalized.appName) \(versionString)",
            purchasedProducts: purchasedProducts,
            appLog: appLog,
            tunnelLog: tunnelLog
        )
    }

    var to: String {
        Constants.shared.emails.issues
    }

    var subject: String {
        Strings.Unlocalized.Issues.subject
    }
}
