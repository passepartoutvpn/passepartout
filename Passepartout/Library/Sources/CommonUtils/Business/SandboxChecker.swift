//
//  SandboxChecker.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/18/22.
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
import StoreKit

// https://stackoverflow.com/a/32238344/784615
// https://gist.github.com/lukaskubanek/cbfcab29c0c93e0e9e0a16ab09586996

public final class SandboxChecker {
    public init() {
    }

    public func isBeta() async -> Bool {
#if !DEBUG
        do {
            guard case .verified(let tx) = try await AppTransaction.shared else {
                return false
            }
            return tx.environment == .sandbox
        } catch {
            return false
        }
#else
        false
#endif
    }
}
