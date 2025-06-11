//
//  AppFeature+Suggestions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/11/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonIAP
import Foundation

extension AppFeature {
    public func individualProducts(on platform: IAPManager.Platform) -> Set<AppProduct> {
        if isEssential {
            var list: Set<AppProduct> = [.Essentials.iOS_macOS]
            switch platform {
            case .iOS:
                list.insert(.Essentials.iOS)
            case .macOS:
                list.insert(.Essentials.macOS)
            case .tvOS:
                break
            }
            return list
        }
        switch self {
        case .appleTV:
            return [.Features.appleTV]
        default:
            assertionFailure("Feature \(rawValue) is outdated or not purchasable individually")
            return []
        }
    }
}
