//
//  AppConstants+Core.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/5/21.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import PassepartoutConstants
import Convenience
import SwiftyBeaver

extension AppConstants.Log {
    public static let level: SwiftyBeaver.Level = .debug

    private static let console: ConsoleDestination = {
        let dest = ConsoleDestination()
        dest.minLevel = level
        dest.useNSLog = true
        return dest
    }()

    private static let file: FileDestination = {
        let dest = FileDestination()
        dest.minLevel = level
        dest.logFileURL = fileURL
        _ = dest.deleteLogFile()
        return dest
    }()
    
    public static func configure() {
        SwiftyBeaver.addDestination(console)
        SwiftyBeaver.addDestination(file)
    }
}

extension AppConstants.Credits {
    public static var software: [Software] {
        return softwareArrays.map {
            switch $0.count {
            case 2:
                return Software($0[0], notice: $0[1])

            case 3:
                return Software($0[0], license: $0[1], url: $0[2])
                
            default:
                fatalError("Not enough Software arguments")
            }
        }
    }
}
