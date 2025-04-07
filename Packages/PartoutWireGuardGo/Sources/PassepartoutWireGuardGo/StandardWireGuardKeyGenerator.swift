//
//  StandardWireGuardKeyGenerator.swift
//  Partout
//
//  Created by Davide De Rosa on 3/25/24.
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
internal import WireGuardKit

public final class StandardWireGuardKeyGenerator: WireGuardKeyGenerator {
    public init() {
    }

    public func newPrivateKey() -> String {
        PrivateKey().base64Key
    }

    public func privateKey(from string: String) throws -> String {
        guard let key = PrivateKey(base64Key: string) else {
            throw PartoutError(.parsing)
        }
        return key.base64Key
    }

    public func publicKey(from string: String) throws -> String {
        guard let key = PublicKey(base64Key: string) else {
            throw PartoutError(.parsing)
        }
        return key.base64Key
    }

    public func publicKey(for privateKey: String) throws -> String {
        guard let key = PrivateKey(base64Key: privateKey) else {
            throw PartoutError(.parsing)
        }
        return key.publicKey.base64Key
    }
}
