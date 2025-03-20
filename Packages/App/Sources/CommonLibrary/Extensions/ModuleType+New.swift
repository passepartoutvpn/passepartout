//
//  ModuleType+New.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/6/24.
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

import Foundation
import PassepartoutKit

extension ModuleType {
    public func newModule(with registry: Registry) -> any ModuleBuilder {
        guard var newBuilder = registry.newModuleBuilder(withModuleType: self) else {
            fatalError("Unknown module type: \(self)")
        }
        switch self {
        case .openVPN:
            guard newBuilder is OpenVPNModule.Builder else {
                fatalError("Unexpected module builder type: \(type(of: newBuilder)) != \(self)")
            }

        case .wireGuard:
            guard var builder = newBuilder as? WireGuardModule.Builder else {
                fatalError("Unexpected module builder type: \(type(of: newBuilder)) != \(self)")
            }
            guard let impl = registry.implementation(for: builder) as? WireGuardModule.Implementation else {
                fatalError("Missing WireGuard implementation for module creation")
            }
            builder.configurationBuilder = WireGuard.Configuration.Builder(keyGenerator: impl.keyGenerator)
            newBuilder = builder

        default:
            break
        }
        return newBuilder
    }
}
