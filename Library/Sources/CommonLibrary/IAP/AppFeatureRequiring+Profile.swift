//
//  AppFeatureRequiring+Profile.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/20/24.
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

extension Profile: AppFeatureRequiring {
    public var features: Set<AppFeature> {
        let builders = activeModules.compactMap { module in
            guard let builder = module.moduleBuilder() else {
                fatalError("Cannot produce ModuleBuilder from Module: \(module)")
            }
            return builder
        }
        return builders.features
    }
}

extension Array: AppFeatureRequiring where Element == any ModuleBuilder {
    public var features: Set<AppFeature> {
        let requirements = compactMap { builder in
            guard let requiring = builder as? AppFeatureRequiring else {
                fatalError("ModuleBuilder does not implement AppFeatureRequiring: \(builder)")
            }
            return requiring
        }
        return Set(requirements.flatMap(\.features))
    }
}
