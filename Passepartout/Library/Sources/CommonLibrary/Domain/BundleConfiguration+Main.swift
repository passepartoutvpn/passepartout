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
        case appStoreId

        case customUserLevel

        case groupId

        case iapBundlePrefix

        case keychainGroupId

        case profilesContainerName

        case tunnelId
    }

    // WARNING: nil from package itself, e.g. in previews
    private static let failableMain: BundleConfiguration? = {
        BundleConfiguration(.main, key: Constants.shared.bundle)
    }()

    private static var main: BundleConfiguration {
        guard let failableMain else {
            fatalError("Missing main bundle")
        }
        return failableMain
    }

    public static var mainDisplayName: String {
        if isPreview {
            return "preview-display-name"
        }
        return main.displayName
    }

    public static var mainVersionString: String {
        if isPreview {
            return "preview-1.2.3"
        }
        return main.versionString
    }

    public static func mainString(for key: BundleKey) -> String {
        if isPreview {
            return "preview-key(\(key.rawValue))"
        }
        guard let value: String = main.value(forKey: key.rawValue) else {
            fatalError("Missing main bundle key: \(key.rawValue)")
        }
        return value
    }

    public static func mainIntegerIfPresent(for key: BundleKey) -> Int? {
        if isPreview {
            return nil
        }
        return main.value(forKey: key.rawValue)
    }
}

private extension BundleConfiguration {
    static var isPreview: Bool {
#if targetEnvironment(simulator)
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
#else
        false
#endif
    }
}
