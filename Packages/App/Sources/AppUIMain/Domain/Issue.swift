//
//  Issue.swift
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

struct Issue: Identifiable {
    let id: UUID

    let comment: String

    let appLine: String?

    let purchasedProducts: Set<AppProduct>

    let providerLastUpdates: [ProviderID: Timestamp]

    let appLog: Data?

    let tunnelLog: Data?

    let osLine: String

    let deviceLine: String?

    init(
        comment: String,
        appLine: String?,
        purchasedProducts: Set<AppProduct>,
        providerLastUpdates: [ProviderID: Timestamp] = [:],
        appLog: Data? = nil,
        tunnelLog: Data? = nil
    ) {
        id = UUID()
        self.comment = comment
        self.appLine = appLine
        self.purchasedProducts = purchasedProducts
        self.appLog = appLog
        self.tunnelLog = tunnelLog
        self.providerLastUpdates = providerLastUpdates

        let systemInfo = SystemInformation()
        osLine = systemInfo.osString
        deviceLine = systemInfo.deviceString
    }

    var body: String {
        let providers = providerLastUpdates.mapValues {
            $0.date.localizedDescription(style: .timestamp)
        }
        return template
            .replacingOccurrences(of: "$comment", with: comment)
            .replacingOccurrences(of: "$appLine", with: appLine ?? "unknown")
            .replacingOccurrences(of: "$osLine", with: osLine)
            .replacingOccurrences(of: "$deviceLine", with: deviceLine ?? "unknown")
            .replacingOccurrences(of: "$providerLastUpdates", with: providers.description)
            .replacingOccurrences(of: "$purchasedProducts", with: purchasedProducts.map(\.rawValue).description)
    }
}

private extension Issue {
    var template: String {
        do {
            guard let templateURL = Bundle.module.url(forResource: "Issue", withExtension: "txt") else {
                fatalError("Unable to find Issue.txt in Resources")
            }
            return try String(contentsOf: templateURL)
        } catch {
            fatalError("Unable to parse Issue.txt: \(error)")
        }
    }
}
