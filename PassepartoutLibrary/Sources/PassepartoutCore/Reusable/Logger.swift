//
//  Logger.swift
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

public enum LoggerLevel: Int {
    case verbose

    case debug

    case info

    case warning

    case error
}

public protocol Logger {
    var logFile: URL? { get }

    var logLevel: LoggerLevel { get }

    func verbose(_ message: Any)

    func debug(_ message: Any)

    func info(_ message: Any)

    func warning(_ message: Any)

    func error(_ message: Any)
}

final class DefaultLogger: Logger {
    let logFile: URL? = nil

    var logLevel: LoggerLevel = .debug

    func verbose(_ message: Any) {
        guard logLevel.rawValue >= LoggerLevel.verbose.rawValue else {
            return
        }
        logMessage(message)
    }

    func debug(_ message: Any) {
        guard logLevel.rawValue >= LoggerLevel.debug.rawValue else {
            return
        }
        logMessage(message)
    }

    func info(_ message: Any) {
        guard logLevel.rawValue >= LoggerLevel.info.rawValue else {
            return
        }
        logMessage(message)
    }

    func warning(_ message: Any) {
        guard logLevel.rawValue >= LoggerLevel.warning.rawValue else {
            return
        }
        logMessage(message)
    }

    func error(_ message: Any) {
        guard logLevel.rawValue >= LoggerLevel.error.rawValue else {
            return
        }
        logMessage(message)
    }

    private func logMessage(_ message: Any) {
        guard let string = message as? String else {
            return
        }
        NSLog(string)
    }
}
