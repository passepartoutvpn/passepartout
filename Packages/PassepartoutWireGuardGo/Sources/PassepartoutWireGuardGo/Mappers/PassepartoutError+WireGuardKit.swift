//
//  PassepartoutError+WireGuardKit.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 3/29/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import PassepartoutKit
internal import WireGuardKit

// MARK: - Mapping

extension WireGuardConnectionError: PassepartoutErrorMappable {
    var asPassepartoutError: PassepartoutError {
        PassepartoutError(.connectionNotStarted, self)
    }
}

extension TunnelConfiguration.ParseError: PassepartoutErrorMappable {
    var asPassepartoutError: PassepartoutError {
        PassepartoutError(.parsing, self)
    }
}
