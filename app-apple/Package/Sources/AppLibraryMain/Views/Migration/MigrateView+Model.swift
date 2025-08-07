// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import Foundation

extension MigrateView {
    struct Model: Equatable {
        var step: MigrateViewStep = .initial

        var profiles: [MigratableProfile] = []

        var statuses: [UUID: MigrationStatus] = [:]

        mutating func excludeFailed() {
            statuses.forEach {
                if statuses[$0.key] == .failed {
                    statuses[$0.key] = .excluded
                }
            }
        }
    }
}

extension MigrateViewStep {
    var isReady: Bool {
        ![.initial, .fetching].contains(self)
    }
}

extension MigrateView.Model {
    var visibleProfiles: [MigratableProfile] {
        profiles
            .sorted {
                switch step {
                case .initial, .fetching, .fetched:
                    return $0.name.lowercased() < $1.name.lowercased()

                case .migrating, .migrated:
                    return (statuses[$0.id].rank, $0.name.lowercased()) < (statuses[$1.id].rank, $1.name.lowercased())
                }
            }
    }
}

private extension Optional where Wrapped == MigrationStatus {
    var rank: Int {
        switch self {
        case .failed:
            return 1

        case .excluded:
            return 2

        default:
            return .min
        }
    }
}
