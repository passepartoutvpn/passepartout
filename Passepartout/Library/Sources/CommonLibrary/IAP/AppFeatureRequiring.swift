//
//  AppFeatureRequiring.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/17/24.
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

public protocol AppFeatureRequiring {
    var features: Set<AppFeature> { get }
}

// MARK: - Profile

extension Profile: AppFeatureRequiring {
    public var features: Set<AppFeature> {
        let requirements = activeModules
            .compactMap { module in
                guard let builder = module.moduleBuilder() else {
                    fatalError("Cannot produce ModuleBuilder from Module \(module.id)")
                }
                return builder as? AppFeatureRequiring
            }

        return Set(requirements.flatMap(\.features))
    }
}

// MARK: - Modules

extension DNSModule.Builder: AppFeatureRequiring {
    public var features: Set<AppFeature> {
        [.dns]
    }
}

extension HTTPProxyModule.Builder: AppFeatureRequiring {
    public var features: Set<AppFeature> {
        [.httpProxy]
    }
}

extension IPModule.Builder: AppFeatureRequiring {
    public var features: Set<AppFeature> {
        [.routing]
    }
}

extension OnDemandModule.Builder: AppFeatureRequiring {
    public var features: Set<AppFeature> {
        guard isEnabled else {
            return []
        }
        return policy != .any ? [.onDemand] : []
    }
}

extension OpenVPNModule.Builder: AppFeatureRequiring {
    public var features: Set<AppFeature> {
        var list: Set<AppFeature> = []
        providerId?.features.forEach {
            list.insert($0)
        }
        if isInteractive {
            list.insert(.interactiveLogin)
        }
        return list
    }
}

extension WireGuardModule.Builder: AppFeatureRequiring {
    public var features: Set<AppFeature> {
        providerId?.features ?? []
    }
}

// MARK: - Providers

extension ProviderID: AppFeatureRequiring {
    public var features: Set<AppFeature> {
        self != .oeck ? [.providers] : []
    }
}
