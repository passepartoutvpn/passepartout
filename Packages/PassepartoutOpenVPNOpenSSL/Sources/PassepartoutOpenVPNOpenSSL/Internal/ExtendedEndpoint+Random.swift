//
//  ExtendedEndpoint+Random.swift
//  Partout
//
//  Created by Davide De Rosa on 3/15/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Partout

extension ExtendedEndpoint {
    func withRandomPrefixLength(_ length: Int, prng: PRNGProtocol) -> ExtendedEndpoint {
        guard isHostname else {
            return self
        }
        let prefix = prng.data(length: length)
        let prefixedAddress = "\(prefix.toHex()).\(address)"
        do {
            return try ExtendedEndpoint(prefixedAddress, proto)
        } catch {
            return self
        }
    }
}

extension OpenVPN.Configuration {
    private static let randomHostnamePrefixLength = 6

    func processedRemotes(prng: PRNGProtocol) -> [ExtendedEndpoint]? {
        guard var processedRemotes = remotes else {
            return nil
        }
        if randomizeEndpoint ?? false {
            processedRemotes.shuffle()
        }
        if let randomPrefixLength = (randomizeHostnames ?? false) ? Self.randomHostnamePrefixLength : nil {
            processedRemotes = processedRemotes.map {
                $0.withRandomPrefixLength(randomPrefixLength, prng: prng)
            }
        }
        return processedRemotes
    }
}
