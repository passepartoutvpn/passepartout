//
//  PassepartoutConfiguration+Logging.swift
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

extension PassepartoutConfiguration {
    public func configureLogging(to url: URL, parameters: Constants.Log, logsPrivateData: Bool) {
        pp_log(.app, .debug, "Log to: \(url)")

        setLocalLogger(options: .init(
            url: url,
            maxNumberOfLines: parameters.maxNumberOfLines,
            maxLevel: parameters.maxLevel,
            mapper: parameters.formatter.formattedLine
        ))

        if logsPrivateData {
            logsAddresses = true
            logsModules = true
        }

        if let maxAge = parameters.maxAge {
            purgeLogs(at: url, beyond: maxAge)
        }
    }

    public func currentLog(parameters: Constants.Log) -> [String] {
        currentLogLines(
            sinceLast: parameters.sinceLast,
            maxLevel: parameters.maxLevel
        )
        .map(parameters.formatter.formattedLine)
    }

    public func availableLogs(at url: URL) -> [Date: URL] {
        let parent = url.deletingLastPathComponent()
        let prefix = url.lastPathComponent
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: parent, includingPropertiesForKeys: nil)
            return contents.reduce(into: [:]) { found, item in
                let filename = item.lastPathComponent
                guard filename.hasPrefix(prefix) else {
                    return
                }
                guard let timestampString = filename.split(separator: ".").last,
                      let timestamp = TimeInterval(timestampString) else {
                    return
                }
                let date = Date(timeIntervalSince1970: timestamp)
                found[date] = item
            }
        } catch {
            return [:]
        }
    }

    public func flushLog() {
        try? saveLog()
    }
}

private extension PassepartoutConfiguration {
    func purgeLogs(at url: URL, beyond maxAge: TimeInterval) {
        let logs = availableLogs(at: url)
        let minDate = Date().addingTimeInterval(-maxAge)
        logs.forEach { date, url in
            guard date >= minDate else {
                try? FileManager.default.removeItem(at: url)
                return
            }
        }
    }
}
