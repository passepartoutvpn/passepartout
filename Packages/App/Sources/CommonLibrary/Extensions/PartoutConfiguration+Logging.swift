//
//  PartoutConfiguration+Logging.swift
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
import PartoutSupport

extension PartoutConfiguration {
    public func configureLogging(to url: URL, parameters: Constants.Log, logsPrivateData: Bool) {
        pp_log(.app, .debug, "Log to: \(url)")

        assertsMissingLoggingCategory = true
        setLogger(OSLogDestination(.api))
        setLogger(OSLogDestination(.app))
        setLogger(OSLogDestination(.core))
        setLogger(OSLogDestination(.ne))
        setLogger(OSLogDestination(.openvpn))
        setLogger(OSLogDestination(.wireguard))
        setLogger(OSLogDestination(.App.iap))
        setLogger(OSLogDestination(.App.migration))
        setLogger(OSLogDestination(.App.profiles))

        setLocalLogger(
            url: url,
            options: parameters.options,
            mapper: parameters.formatter.formattedLine
        )

        if logsPrivateData {
            logsAddresses = true
            logsModules = true
        }

        appendLog(parameters.options.maxLevel, message: "")
        appendLog(parameters.options.maxLevel, message: "--- BEGIN ---")
        appendLog(parameters.options.maxLevel, message: "")

        let systemInfo = SystemInformation()
        appendLog(parameters.options.maxLevel, message: "App: \(BundleConfiguration.mainVersionString)")
        appendLog(parameters.options.maxLevel, message: "OS: \(systemInfo.osString)")
        if let deviceString = systemInfo.deviceString {
            appendLog(parameters.options.maxLevel, message: "Device: \(deviceString)")
        }
        appendLog(parameters.options.maxLevel, message: "")
    }

    public func currentLog(parameters: Constants.Log) -> [String] {
        currentLogLines(
            sinceLast: parameters.sinceLast,
            maxLevel: parameters.options.maxLevel
        )
        .map(parameters.formatter.formattedLine)
    }
}
