//
//  Utils+Dates.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/26/22.
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

private let timestampFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateStyle = .medium
    fmt.timeStyle = .medium
    return fmt
}()

private let componentsFormatter: DateComponentsFormatter = {
    let fmt = DateComponentsFormatter()
    fmt.unitsStyle = .full
    return fmt
}()

extension Date {
    public var timestamp: String {
        timestampFormatter.string(from: self)
    }
}

extension TimeInterval {
    public var localizedDescription: String {
        guard let str = componentsFormatter.string(from: self) else {
            fatalError("Could not format a TimeInterval?")
        }
        return str
    }
}
