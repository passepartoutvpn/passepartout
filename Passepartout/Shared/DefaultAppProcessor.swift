//
//  DefaultAppProcessor.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/6/24.
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

public final class DefaultAppProcessor: Sendable {
    private let iapManager: IAPManager

    private let preview: @Sendable (Profile) -> ProfilePreview

    public init(iapManager: IAPManager, preview: @escaping @Sendable (Profile) -> ProfilePreview) {
        self.iapManager = iapManager
        self.preview = preview
    }
}

extension DefaultAppProcessor: ProfileProcessor {
    public func isIncluded(_ profile: Profile) -> Bool {
        Dependencies.ProfileManager.isIncluded(iapManager, profile)
    }

    public func preview(from profile: Profile) -> ProfilePreview {
        preview(profile)
    }

    public func requiredFeatures(_ profile: Profile) -> Set<AppFeature>? {
        do {
            try iapManager.verify(profile)
            return nil
        } catch AppError.ineligibleProfile(let requiredFeatures) {
            return requiredFeatures
        } catch {
            return nil
        }
    }

    public func willRebuild(_ builder: Profile.Builder) throws -> Profile.Builder {
        builder
    }
}

extension DefaultAppProcessor: AppTunnelProcessor {
    public func title(for profile: Profile) -> String {
        Dependencies.ProfileManager.sharedTitle(profile)
    }

    public func willInstall(_ profile: Profile) throws -> Profile {
        try iapManager.verify(profile)

        // validate provider modules
        do {
            _ = try profile.withProviderModules()
            return profile
        } catch {
            pp_log(.app, .error, "Unable to inject provider modules: \(error)")
            throw error
        }
    }
}
