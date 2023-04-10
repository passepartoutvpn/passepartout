//
//  Constants.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/7/18.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

enum Constants {
    static func bundleConfig<T>(_ key: String, in bundle: Bundle? = nil) -> T {
        guard let config = (bundle ?? .main).infoDictionary?["com.algoritmico.Passepartout.config"] as? [String: Any] else {
            fatalError("Unable to find config bundle")
        }
        guard let value = config[key] as? T else {
            fatalError("Missing \(key) from config bundle")
        }
        return value
    }

    enum Global {
        static let appName = "Passepartout"

        static let appVersionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

        static let appBuildNumber = Int(Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String)!

        static let appVersionString = "\(appVersionNumber) (\(appBuildNumber))"
    }
}
