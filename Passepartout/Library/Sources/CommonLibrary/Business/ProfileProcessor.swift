//
//  ProfileProcessor.swift
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

public final class ProfileProcessor: ObservableObject, Sendable {
    private let iapManager: IAPManager

    public nonisolated let title: (Profile) -> String

    private nonisolated let _isIncluded: (IAPManager, Profile) -> Bool

    private nonisolated let _willSave: (IAPManager, Profile.Builder) throws -> Profile.Builder

    private nonisolated let _willConnect: (IAPManager, Profile) throws -> Profile

    public init(
        iapManager: IAPManager,
        title: @escaping (Profile) -> String,
        isIncluded: @escaping (IAPManager, Profile) -> Bool,
        willSave: @escaping (IAPManager, Profile.Builder) throws -> Profile.Builder,
        willConnect: @escaping (IAPManager, Profile) throws -> Profile
    ) {
        self.iapManager = iapManager
        self.title = title
        _isIncluded = isIncluded
        _willSave = willSave
        _willConnect = willConnect
    }

    public func isIncluded(_ profile: Profile) -> Bool {
        _isIncluded(iapManager, profile)
    }

    public func willSave(_ builder: Profile.Builder) throws -> Profile.Builder {
        try _willSave(iapManager, builder)
    }

    public func willConnect(_ profile: Profile) throws -> Profile {
        try _willConnect(iapManager, profile)
    }
}
