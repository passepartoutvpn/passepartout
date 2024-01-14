//
//  Logger.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/15/22.
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

public enum LoggerLevel: Int {
    case verbose

    case debug

    case info

    case warning

    case error
}

public protocol Logger {
    var logFile: URL? { get }

    var logLevel: LoggerLevel { get set }

    func logMessage(_ level: LoggerLevel, _ message: Any, _ file: String, _ function: String, _ line: Int)
}

extension Logger {
    public func verbose(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        logMessage(.verbose, message, file, function, line)
    }

    public func debug(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        logMessage(.debug, message, file, function, line)
    }

    public func info(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        logMessage(.info, message, file, function, line)
    }

    public func warning(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        logMessage(.warning, message, file, function, line)
    }

    public func error(_ message: Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        logMessage(.error, message, file, function, line)
    }
}

public protocol Loggable {
    var logDescription: String { get }
}

final class DefaultLogger: Logger {
    let logFile: URL? = nil

    var logLevel: LoggerLevel = .debug

    func logMessage(_ level: LoggerLevel, _ message: Any, _ file: String, _ function: String, _ line: Int) {
        guard level.rawValue >= logLevel.rawValue else {
            return
        }
        guard let string = message as? String else {
            return
        }
        NSLog(string)
    }
}
