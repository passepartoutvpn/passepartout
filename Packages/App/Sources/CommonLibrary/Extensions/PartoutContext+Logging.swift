//
//  PartoutContext+Logging.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/4/24.
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

extension PartoutContext.Builder {
    public mutating func configureLogging(to url: URL, parameters: Constants.Log, logsPrivateData: Bool) {
        if let profileId {
            pp_log(nil, .app, .debug, "Log profile \(profileId) to: \(url)")
        } else {
            pp_log(nil, .app, .debug, "Log globally to: \(url)")
        }

        assertsMissingLoggingCategory = true
        setOSLog(for: [
            .api,
            .app,
            .core,
            .ne,
            .openvpn,
            .providers,
            .wireguard,
            .App.iap,
            .App.migration,
            .App.profiles
        ])

        setLocalLogger(
            url: url,
            options: parameters.options,
            mapper: parameters.formatter.formattedLine
        )

        if logsPrivateData {
            logsAddresses = true
            logsModules = true
        }
    }
}

extension PartoutContext {
    public func currentLog(parameters: Constants.Log) -> [String] {
        currentLogLines(
            sinceLast: parameters.sinceLast,
            maxLevel: parameters.options.maxLevel
        )
        .map(parameters.formatter.formattedLine)
    }
}

private extension PartoutContext.Builder {
    mutating func setOSLog(for categories: [LoggerCategory]) {
        categories.forEach {
            setLogger(OSLogDestination($0), for: [$0])
        }
    }
}
