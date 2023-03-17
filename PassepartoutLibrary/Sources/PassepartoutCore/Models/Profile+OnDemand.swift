//
//  Profile+OnDemand.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/22.
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

extension Profile {
    public struct OnDemand: Codable, Equatable {
        public enum Policy: String, Codable {
            case any

            case including

            case excluding // "trusted networks"
        }

        public enum OtherNetwork: String, Codable {
            case mobile

            case ethernet
        }

        // hardcode this to keep "Trusted networks" semantics
        public var isEnabled = true

        // hardcode this to keep "Trusted networks" semantics
        public var policy: Policy = .excluding

        public var withSSIDs: [String: Bool] = [:]

        public var withOtherNetworks: Set<OtherNetwork> = []

        public var disconnectsIfNotMatching = true

        public init() {
        }
    }
}
