//
//  Profile+Account.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/22.
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
    public struct Account: Codable, Equatable {
        public enum AuthenticationMethod: String, Codable {
            case persistent

            case interactive

            case totp
        }

        public var authenticationMethod: AuthenticationMethod?

        public var username: String

        public var password: String

        public var isEmpty: Bool {
            username.isEmpty && password.isEmpty
        }

        public init() {
            username = ""
            password = ""
        }

        public init(_ username: String, _ password: String) {
            self.username = username
            self.password = password
        }
    }
}
