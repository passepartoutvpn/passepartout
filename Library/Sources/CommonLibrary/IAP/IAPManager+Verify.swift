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
    public func verify(_ profile: Profile, isShared: Bool = false) throws {
        var features = profile.features
        if isShared {
            features.insert(.sharing)
        }
        try verify(features)
    }

    public func verify(_ modulesBuilders: [any ModuleBuilder], isShared: Bool = false) throws {
        var features = modulesBuilders.features
        if isShared {
            features.insert(.sharing)
        }
        try verify(features)
    }

    public func verify(_ features: Set<AppFeature>) throws {
#if os(tvOS)
        guard isEligible(for: .appleTV) else {
            throw AppError.ineligibleProfile([.appleTV])
        }
#endif
        let requiredFeatures = features.filter {
            !isEligible(for: $0)
        }
        guard requiredFeatures.isEmpty else {
            throw AppError.ineligibleProfile(requiredFeatures)
        }
    }
}
