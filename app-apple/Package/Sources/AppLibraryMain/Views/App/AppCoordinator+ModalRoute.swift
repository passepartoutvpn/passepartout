// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

extension AppCoordinator {
    enum ModalRoute: Identifiable {
        case editProfile
        case editProviderEntity(Profile, Bool, Module)
        case interactiveLogin
        case migrateProfiles
        case settings
        case systemExtension

        var id: Int {
            switch self {
            case .editProfile: return 1
            case .editProviderEntity: return 2
            case .interactiveLogin: return 3
            case .migrateProfiles: return 4
            case .settings: return 5
            case .systemExtension: return 6
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

    enum ConfirmationAction {
        case deleteProfile(ProfilePreview)
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
        case .systemExtension:
            return .small
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
