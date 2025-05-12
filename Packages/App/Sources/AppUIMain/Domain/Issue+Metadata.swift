//
//  Issue+Metadata.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/18/24.
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

extension Issue {
    struct Metadata {
        let profile: Profile?

        let provider: (ProviderID, Date?)?

        let configuration: PartoutConfiguration

        let versionString: String

        let purchasedProducts: Set<AppProduct>

        let tunnel: ExtendedTunnel

        let urlForTunnelLog: URL

        let parameters: Constants.Log

        let comment: String
    }

    @MainActor
    static func withMetadata(_ metadata: Metadata) async -> Issue {
        let appLog = metadata.configuration.currentLog(parameters: metadata.parameters)
            .joined(separator: "\n")
            .data(using: .utf8)

        let tunnelLog: Data?

        // FIXME: #1360, diagnostics/logs must be per-tunnel
        // live tunnel log
        if !metadata.tunnel.activeProfiles.isEmpty {
            tunnelLog = await metadata.tunnel.currentLog(parameters: metadata.parameters)
                .joined(separator: "\n")
                .data(using: .utf8)
        }
        // latest persisted tunnel log
        else if let latestTunnelEntry = metadata.configuration.availableLogs(at: metadata.urlForTunnelLog)
            .max(by: { $0.key < $1.key }) {

            tunnelLog = try? Data(contentsOf: latestTunnelEntry.value)
        }
        // nothing
        else {
            tunnelLog = nil
        }

        return Issue(
            comment: metadata.comment,
            appLine: "\(Strings.Unlocalized.appName) \(metadata.versionString)",
            purchasedProducts: metadata.purchasedProducts,
            appLog: appLog,
            tunnelLog: tunnelLog,
            provider: metadata.provider
        )
    }
}

extension Issue {
    var to: String {
        Constants.shared.emails.issues
    }

    var subject: String {
        Strings.Unlocalized.Issues.subject
    }
}
