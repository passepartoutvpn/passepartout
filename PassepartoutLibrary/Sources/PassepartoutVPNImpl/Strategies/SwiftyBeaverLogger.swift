//
//  SwiftyBeaverLogger.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/21/23.
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
import PassepartoutCore
import SwiftyBeaver

public final class SwiftyBeaverLogger: Logger {
    public let logFile: URL?

    public init(logFile: URL?, logLevel: SwiftyBeaver.Level = .info, logFormat: String? = nil) {
        self.logFile = logFile

        let console = ConsoleDestination()
        console.minLevel = logLevel
//        console.useNSLog = true
        if let logFormat {
            console.format = logFormat
        }
        SwiftyBeaver.addDestination(console)

        if let logFile {
            let file = FileDestination()
            file.minLevel = logLevel
            file.logFileURL = logFile
            if let logFormat {
                file.format = logFormat
            }
            _ = file.deleteLogFile()
            SwiftyBeaver.addDestination(file)
        }
    }

    public func error(_ message: Any) {
        SwiftyBeaver.error(message)
    }

    public func warning(_ message: Any) {
        SwiftyBeaver.warning(message)
    }

    public func info(_ message: Any) {
        SwiftyBeaver.info(message)
    }

    public func debug(_ message: Any) {
        SwiftyBeaver.debug(message)
    }

    public func verbose(_ message: Any) {
        SwiftyBeaver.verbose(message)
    }
}
