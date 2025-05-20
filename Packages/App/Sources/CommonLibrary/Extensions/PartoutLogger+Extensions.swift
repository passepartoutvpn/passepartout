//
//  PartoutLogger+Extensions.swift
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

extension PartoutLogger {
    public enum Target {
        case app

        case tunnel(Profile.ID)
    }

    @discardableResult
    public static func register(
        for target: Target,
        with preferences: AppPreferenceValues
    ) -> PartoutLoggerContext {
        switch target {
        case .app:
            let logger = appLogger(preferences: preferences)
            PartoutLogger.register(logger)
            logger.logPreamble(parameters: Constants.shared.log)
            return .global
        case .tunnel(let profileId):
            let logger = tunnelLogger(preferences: preferences)
            PartoutLogger.register(logger)
            logger.logPreamble(parameters: Constants.shared.log)
            return PartoutLoggerContext(profileId)
        }
    }
}

private extension PartoutLogger {
    static func appLogger(preferences: AppPreferenceValues) -> PartoutLogger {
        var builder = PartoutLogger.Builder()
        builder.configureLogging(
            to: BundleConfiguration.urlForAppLog,
            parameters: Constants.shared.log,
            logsPrivateData: preferences.logsPrivateData
        )
        return builder.build()
    }

    static func tunnelLogger(preferences: AppPreferenceValues) -> PartoutLogger {
        var builder = PartoutLogger.Builder()
        builder.configureLogging(
            to: BundleConfiguration.urlForTunnelLog,
            parameters: Constants.shared.log,
            logsPrivateData: preferences.logsPrivateData
        )
        builder.willPrint = {
            let prefix = "[\($0.profileId?.uuidString.prefix(8) ?? "global")]"
            return "\(prefix) \($1)"
        }
        return builder.build()
    }

    func logPreamble(parameters: Constants.Log) {
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

        if let url = localLoggerURL {
            pp_log(.global, .app, .debug, "Log to: \(url)")
        }
    }
}

extension PartoutLogger {
    public func currentLog(parameters: Constants.Log) -> [String] {
        currentLogLines(
            sinceLast: parameters.sinceLast,
            maxLevel: parameters.options.maxLevel
        )
        .map(parameters.formatter.formattedLine)
    }
}

private extension PartoutLogger.Builder {
    mutating func configureLogging(to url: URL, parameters: Constants.Log, logsPrivateData: Bool) {
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

    mutating func setOSLog(for categories: [LoggerCategory]) {
        categories.forEach {
            setDestination(OSLogDestination($0), for: [$0])
        }
    }
}
