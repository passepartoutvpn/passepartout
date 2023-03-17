//
//  LogManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/15/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import SwiftyBeaver

@MainActor
public class LogManager {
    public let logFile: URL?

    public var logLevel: SwiftyBeaver.Level = .info

    public var logFormat: String?

    public init(logFile: URL?) {
        self.logFile = logFile
    }

    public func configureLogging() {
        let console = ConsoleDestination()
        console.minLevel = logLevel
//        console.useNSLog = true
        if let logFormat = logFormat {
            console.format = logFormat
        }
        SwiftyBeaver.addDestination(console)

        if let fileURL = logFile {
            let file = FileDestination()
            file.minLevel = logLevel
            file.logFileURL = fileURL
            if let logFormat = logFormat {
                file.format = logFormat
            }
            _ = file.deleteLogFile()
            SwiftyBeaver.addDestination(file)
        }
    }
}
