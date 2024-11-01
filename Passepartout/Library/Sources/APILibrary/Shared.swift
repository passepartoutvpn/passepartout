//
//  Shared.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
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

import CommonLibrary
import Foundation
import PassepartoutKit

// TODO: #716, move to Environment
extension API {
    public static var shared: [APIMapper] {
#if DEBUG
        [API.bundled]
#else
        API.remoteThenBundled
#endif
    }

    private static let remoteThenBundled: [APIMapper] = [
        Self.remote,
        Self.bundled
    ]

    public static let bundled: APIMapper = {
        guard let url = Bundle.module.url(forResource: "API", withExtension: nil) else {
            fatalError("Unable to find bundled API")
        }
        let ws = API.V5.DefaultWebServices(
            url,
            timeout: Constants.shared.api.timeoutInterval
        )
        return API.V5.Mapper(webServices: ws)
    }()

    public static let remote: APIMapper = {
        let ws = API.V5.DefaultWebServices(
            Constants.shared.websites.api,
            timeout: Constants.shared.api.timeoutInterval
        )
        return API.V5.Mapper(webServices: ws)
    }()
}
