//
//  BundleConfiguration+Main.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/1/24.
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

extension BundleConfiguration {
    public enum BundleKey: String {
        case appId

        case appStoreId

        case customUserLevel

        case groupId

        case iapBundlePrefix

        case keychainGroupId

        case profilesContainerName

        case teamId

        case tunnelId
    }

    // WARNING: nil from package itself, e.g. in previews
    static let failableMain: BundleConfiguration? = {
        BundleConfiguration(.main, key: "AppConfig")
    }()

    public static let main: BundleConfiguration = {
        guard let failableMain else {
            fatalError("Unable to build BundleConfiguration")
        }
        return failableMain
    }()

    public func string(for key: BundleKey) -> String {
        guard let value: String = value(forKey: key.rawValue) else {
            fatalError("Key '\(key)' not found in bundle")
        }
        return value
    }

    public func integerIfPresent(for key: BundleKey) -> Int? {
        value(forKey: key.rawValue)
    }
}
