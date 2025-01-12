//
//  MockProfileRepository.swift
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

import CommonLibrary
import Foundation
import PassepartoutKit

final class MockProfileProcessor: ProfileProcessor {
    var isIncludedCount = 0

    var isIncludedBlock: (Profile) -> Bool = { _ in true }

    var requiredFeaturesCount = 0

    var requiredFeatures: Set<AppFeature>?

    var willRebuildCount = 0

    func title(for profile: Profile) -> String {
        profile.name
    }

    func isIncluded(_ profile: Profile) -> Bool {
        isIncludedCount += 1
        return isIncludedBlock(profile)
    }

    func preview(from profile: Profile) -> ProfilePreview {
        ProfilePreview(profile)
    }

    func requiredFeatures(_ profile: Profile) -> Set<AppFeature>? {
        requiredFeaturesCount += 1
        return requiredFeatures
    }

    func willRebuild(_ builder: Profile.Builder) throws -> Profile.Builder {
        willRebuildCount += 1
        return builder
    }
}
