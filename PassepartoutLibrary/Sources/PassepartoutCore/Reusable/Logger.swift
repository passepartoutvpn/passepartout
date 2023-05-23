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

public enum LoggerLevel {
    case error

    case warning

    case info

    case debug
}

public protocol Logger {
    var logFile: URL? { get }

    func error(_ message: Any)

    func warning(_ message: Any)

    func info(_ message: Any)

    func debug(_ message: Any)

    func verbose(_ message: Any)
}

final class DefaultLogger: Logger {
    let logFile: URL? = nil

    func error(_ message: Any) {
        logMessage(message)
    }

    func warning(_ message: Any) {
        logMessage(message)
    }

    func info(_ message: Any) {
        logMessage(message)
    }

    func debug(_ message: Any) {
        logMessage(message)
    }

    func verbose(_ message: Any) {
        logMessage(message)
    }

    private func logMessage(_ message: Any) {
        guard let string = message as? String else {
            return
        }
        NSLog(string)
    }
}
