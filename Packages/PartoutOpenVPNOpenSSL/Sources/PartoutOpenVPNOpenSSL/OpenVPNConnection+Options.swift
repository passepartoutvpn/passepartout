//
//  OpenVPNConnection+Options.swift
//  Partout
//
//  Created by Davide De Rosa on 1/13/25.
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

extension OpenVPN {

    /// The options for ``OpenVPNSession``. Intervals are expressed in seconds.
    public struct ConnectionOptions: Sendable {
        public var maxPackets: Int = 100

        public var writeTimeout: TimeInterval = 5.0

        public var minDataCountInterval: TimeInterval = 3.0

        public var negotiationTimeout: TimeInterval = 30.0

        public var hardResetTimeout: TimeInterval = 10.0

        public var tickInterval: TimeInterval = 0.2

        public var retxInterval: TimeInterval = 0.1

        public var pushRequestInterval: TimeInterval = 2.0

        public var pingTimeoutCheckInterval: TimeInterval = 10.0

        public var pingTimeout: TimeInterval = 120.0

        public var softNegotiationTimeout: TimeInterval = 120.0

        public init() {
        }
    }
}
