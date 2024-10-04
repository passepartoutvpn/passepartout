//
//  ReportIssueButton+macOS.swift
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

#if os(macOS)

import CommonLibrary
import PassepartoutKit
import SwiftUI

extension ReportIssueButton: View {
    var body: some View {
        Button(title) {
            guard let service = NSSharingService(named: .composeEmail) else {
                isUnableToEmail = true
                return
            }
            Task {
                let issue = await Issue.with(.init(
                    configuration: .shared,
                    versionString: BundleConfiguration.mainVersionString,
                    purchasedProducts: purchasedProducts,
                    tunnel: tunnel,
                    urlForTunnelLog: BundleConfiguration.urlForTunnelLog,
                    parameters: Constants.shared.log
                ))
                service.recipients = [issue.to]
                service.subject = issue.subject
                service.perform(withItems: issue.items)
            }
        }
    }
}

private extension Issue {
    var items: [Any] {
        var list: [Any] = []
        list.append(body)
        if let appLog, let url = appLog.toTemporaryURL(withFilename: Strings.Unlocalized.Issues.appLogFilename) {
            list.append(url)
        }
        if let tunnelLog, let url = tunnelLog.toTemporaryURL(withFilename: Strings.Unlocalized.Issues.tunnelLogFilename) {
            list.append(url)
        }
        return list
    }
}

#endif
