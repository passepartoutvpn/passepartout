//
//  AppCoordinator+ModalRoute.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/29/24.
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

import Foundation
import Partout

extension AppCoordinator {
    enum ModalRoute: Identifiable {
        case editProfile

        case editProviderEntity(Profile, Bool, Module)

        case interactiveLogin

        case migrateProfiles

        case settings

        var id: Int {
            switch self {
            case .editProfile: return 1
            case .editProviderEntity: return 2
            case .interactiveLogin: return 3
            case .migrateProfiles: return 4
            case .settings: return 5
            }
        }

        func options() -> ThemeModalOptions {
            var options = ThemeModalOptions()
            options.size = size
            options.isFixedWidth = isFixedWidth
            options.isFixedHeight = isFixedHeight
            options.isInteractive = isInteractive
            return options
        }
    }
}

extension AppCoordinator.ModalRoute: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

private extension AppCoordinator.ModalRoute {
    var size: ThemeModalSize {
        switch self {
        case .interactiveLogin:
            return .custom(width: 500, height: 200)
        case .migrateProfiles:
            return .custom(width: 700, height: 400)
        default:
            return .large
        }
    }

    var isFixedWidth: Bool {
        switch self {
        case .migrateProfiles:
            return true
        default:
            return false
        }
    }

    var isFixedHeight: Bool {
        switch self {
        case .migrateProfiles:
            return true
        default:
            return false
        }
    }

    var isInteractive: Bool {
        switch self {
        case .editProfile:
            return false
        default:
            return true
        }
    }
}
