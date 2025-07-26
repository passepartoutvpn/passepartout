// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

enum MigrateViewStep: Equatable {
    case initial

    case fetching

    case fetched([MigratableProfile])

    case migrating

    case migrated([Profile])

    var canSelect: Bool {
        guard case .fetched = self else {
            return false
        }
        return true
    }
}
