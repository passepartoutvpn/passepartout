//
//  MigrateView+Model.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/14/24.
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

import CommonLibrary
import Foundation
import PassepartoutKit

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
