//
//  MockAppProcessor.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/8/24.
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

final class MockAppProcessor {
    private let iapManager: IAPManager

    init(iapManager: IAPManager) {
        self.iapManager = iapManager
    }
}

extension MockAppProcessor: ProfileProcessor {
    func isIncluded(_ profile: Profile) -> Bool {
        true
    }

    func preview(from profile: Profile) -> ProfilePreview {
        profile.localizedPreview
    }

    func requiredFeatures(_ profile: Profile) -> Set<AppFeature>? {
        nil
    }

    func willRebuild(_ builder: Profile.Builder) throws -> Profile.Builder {
        builder
    }
}

extension MockAppProcessor: AppTunnelProcessor {
    func title(for profile: Profile) -> String {
        "Passepartout.Mock: \(profile.name)"
    }

    func willInstall(_ profile: Profile) throws -> Profile {
        profile
    }
}
