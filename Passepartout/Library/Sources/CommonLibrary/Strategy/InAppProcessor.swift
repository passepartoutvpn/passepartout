//
//  InAppProcessor.swift
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

import Foundation
import PassepartoutKit

public final class InAppProcessor: ObservableObject, Sendable {
    private let iapManager: IAPManager

    public nonisolated let _title: (Profile) -> String

    private nonisolated let _isIncluded: (IAPManager, Profile) -> Bool

    private nonisolated let _preview: (Profile) -> ProfilePreview

    private nonisolated let _verify: (IAPManager, Profile) -> Set<AppFeature>?

    private nonisolated let _willRebuild: (IAPManager, Profile.Builder) throws -> Profile.Builder

    private nonisolated let _willInstall: (IAPManager, Profile) throws -> Profile

    public init(
        iapManager: IAPManager,
        title: @escaping (Profile) -> String,
        isIncluded: @escaping (IAPManager, Profile) -> Bool,
        preview: @escaping (Profile) -> ProfilePreview,
        verify: @escaping (IAPManager, Profile) -> Set<AppFeature>?,
        willRebuild: @escaping (IAPManager, Profile.Builder) throws -> Profile.Builder,
        willInstall: @escaping (IAPManager, Profile) throws -> Profile
    ) {
        self.iapManager = iapManager
        _title = title
        _isIncluded = isIncluded
        _preview = preview
        _verify = verify
        _willRebuild = willRebuild
        _willInstall = willInstall
    }
}

// MARK: - ProfileProcessor

extension InAppProcessor: ProfileProcessor {
    public func title(for profile: Profile) -> String {
        _title(profile)
    }

    public func isIncluded(_ profile: Profile) -> Bool {
        _isIncluded(iapManager, profile)
    }

    public func preview(from profile: Profile) -> ProfilePreview {
        _preview(profile)
    }

    public func verify(_ profile: Profile) -> Set<AppFeature>? {
        _verify(iapManager, profile)
    }

    public func willRebuild(_ builder: Profile.Builder) throws -> Profile.Builder {
        try _willRebuild(iapManager, builder)
    }
}

// MARK: - TunnelProcessor

extension InAppProcessor: TunnelProcessor {
    public func willInstall(_ profile: Profile) throws -> Profile {
        try _willInstall(iapManager, profile)
    }
}
