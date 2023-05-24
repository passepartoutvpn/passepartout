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

    public var logLevel: LoggerLevel {
        didSet {
            SwiftyBeaver.destinations.forEach {
                $0.minLevel = logLevel.toSwiftyBeaver
            }
        }
    }

    public init(logFile: URL?, logLevel: LoggerLevel = .info, logFormat: String? = nil) {
        self.logFile = logFile
        self.logLevel = logLevel

        let console = ConsoleDestination()
        console.minLevel = logLevel.toSwiftyBeaver
//        console.useNSLog = true
        if let logFormat {
            console.format = logFormat
        }
        SwiftyBeaver.addDestination(console)

        if let logFile {
            let file = FileDestination()
            file.minLevel = logLevel.toSwiftyBeaver
            file.logFileURL = logFile
            if let logFormat {
                file.format = logFormat
            }
            _ = file.deleteLogFile()
            SwiftyBeaver.addDestination(file)
        }
    }

    public func verbose(_ message: Any) {
        SwiftyBeaver.verbose(message)
    }

    public func debug(_ message: Any) {
        SwiftyBeaver.debug(message)
    }

    public func info(_ message: Any) {
        SwiftyBeaver.info(message)
    }

    public func warning(_ message: Any) {
        SwiftyBeaver.warning(message)
    }

    public func error(_ message: Any) {
        SwiftyBeaver.error(message)
    }
}

private extension LoggerLevel {
    var toSwiftyBeaver: SwiftyBeaver.Level {
        switch self {
        case .verbose: return .verbose
        case .debug: return .debug
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        }
    }
}
