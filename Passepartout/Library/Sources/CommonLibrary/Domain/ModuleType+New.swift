//
//  ModuleType+New.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/6/24.
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
import PassepartoutKit

extension ModuleType {
    public func newModule(with registry: Registry) -> any ModuleBuilder {
        switch self {
        case .openVPN:
            return OpenVPNModule.Builder()

        case .wireGuard:
            let impl = registry.implementation(for: WireGuardModule.moduleHandler.id)
            guard let wireGuard = impl as? WireGuardModule.Implementation else {
                fatalError("Missing WireGuardModule implementation from Registry?")
            }
            return WireGuardModule.Builder(configurationBuilder: .init(keyGenerator: wireGuard.keyGenerator))

        case .dns:
            return DNSModule.Builder()

        case .httpProxy:
            return HTTPProxyModule.Builder()

        case .ip:
            return IPModule.Builder()

        case .onDemand:
            var builder = OnDemandModule.Builder()
            builder.policy = .any
            return builder

        default:
            fatalError("Unknown module type: \(rawValue)")
        }
    }
}