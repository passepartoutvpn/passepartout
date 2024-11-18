//
//  IAPManager+Verify.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/18/24.
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

extension IAPManager {
    public func verify(_ modules: [Module]) throws {
        let builders = modules.map {
            guard let builder = $0.moduleBuilder() else {
                fatalError("Cannot produce ModuleBuilder from Module for IAPManager.verify(): \($0)")
            }
            return builder
        }
        try verify(builders)
    }

    public func verify(_ modulesBuilders: [any ModuleBuilder]) throws {
#if os(tvOS)
        guard isEligible(for: .appleTV) else {
            throw AppError.ineligibleProfile([.appleTV])
        }
#endif
        let requirements: [(UUID, Set<AppFeature>)] = modulesBuilders
            .compactMap { builder in
                guard let requiring = builder as? AppFeatureRequiring else {
                    return nil
                }
                return (builder.id, requiring.features)
            }

        let requiredFeatures = Set(requirements
            .flatMap(\.1)
            .filter {
                !isEligible(for: $0)
            })

        guard requiredFeatures.isEmpty else {
            throw AppError.ineligibleProfile(requiredFeatures)
        }
    }
}
