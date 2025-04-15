//
//  Shared.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import Foundation

// TODO: #716, move to Environment
extension API {
    public static var shared: [APIMapper] {
#if DEBUG
        API.bundled
#else
        API.remoteThenBundled
#endif
    }

    public static let bundled: [APIMapper] = [
        Self.bundledV6
    ]

    private static let remoteThenBundled: [APIMapper] = [
        Self.remoteV6,
        Self.bundledV6
    ]
}

private extension API {

    // use local JS (baseURL = local)
    // fetch remote JSON (URL in scripts)
    static let bundledV6: APIMapper = {
        guard let bundledURL = Bundle.module.url(forResource: "API/v6", withExtension: nil) else {
            fatalError("Unable to find bundled API")
        }
        return API.V6.Mapper(baseURL: bundledURL)
    }()

    // fetch remote JS (baseURL = remote)
    // fetch remote JSON (URL in scripts)
    static let remoteV6: APIMapper = {
        let remoteURL = Constants.shared.websites.api.appendingPathComponent("v6")
        return API.V6.Mapper(baseURL: remoteURL)
    }()
}
