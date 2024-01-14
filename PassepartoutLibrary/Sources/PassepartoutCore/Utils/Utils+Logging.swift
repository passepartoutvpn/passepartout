//
//  Utils+Logging.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/24/22.
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

extension Utils {
    public static func assertCoreDataDecodingFailed(
        _ message: String? = nil,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line
    ) {
//        assertionFailure(message ?? "Cannot decode entity required fields", file, function, line)
        pp_log.warning(message ?? "Cannot decode entity required fields", file, function, line)
    }

    public static func logFetchError(
        _ error: Error,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line
    ) {
        pp_log.error("Unable to fetch: \(error)", file, function, line)
    }

    public static func logFetchNotFound(
        _ query: String,
        _ file: String = #file,
        _ function: String = #function,
        _ line: Int = #line
    ) {
        pp_log.debug("Entity not found: (\(query))", file, function, line)
    }
}
