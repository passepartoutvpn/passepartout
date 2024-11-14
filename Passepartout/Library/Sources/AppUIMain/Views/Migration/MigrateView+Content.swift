//
//  MigrateView+Content.swift
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
import PassepartoutKit
import SwiftUI

extension MigrateView {
    struct ContentView: View {
        let style: Style

        let step: Model.Step

        let profiles: [MigratableProfile]

        @Binding
        var excluded: Set<UUID>

        let statuses: [UUID: MigrationStatus]

        var body: some View {
            switch style {
            case .section:
                MigrateView.SectionView(
                    step: step,
                    profiles: sortedProfiles,
                    excluded: $excluded,
                    statuses: statuses
                )

            case .table:
                MigrateView.TableView(
                    step: step,
                    profiles: sortedProfiles,
                    excluded: $excluded,
                    statuses: statuses
                )
            }
        }

        var sortedProfiles: [MigratableProfile] {
            profiles.sorted {
                $0.name.lowercased() < $1.name.lowercased()
            }
        }
    }
}

// MARK: - Previews

#Preview("Fetched") {
    PrivatePreviews.MigratePreview(
        step: .fetched,
        profiles: PrivatePreviews.profiles,
        statuses: [:]
    )
    .withMockEnvironment()
}

#Preview("Migrated") {
    PrivatePreviews.MigratePreview(
        step: .migrated([]),
        profiles: PrivatePreviews.profiles,
        statuses: [
            PrivatePreviews.profiles[0].id: .excluded,
            PrivatePreviews.profiles[1].id: .pending,
            PrivatePreviews.profiles[2].id: .failure,
            PrivatePreviews.profiles[3].id: .success
        ]
    )
    .withMockEnvironment()
}

private struct PrivatePreviews {
    static let oneDay: TimeInterval = 24 * 60 * 60

    static let profiles: [MigratableProfile] = [
        .init(id: UUID(), name: "1One", lastUpdate: Date().addingTimeInterval(-oneDay)),
        .init(id: UUID(), name: "2Two", lastUpdate: Date().addingTimeInterval(-3 * oneDay)),
        .init(id: UUID(), name: "3Three", lastUpdate: Date().addingTimeInterval(-90 * oneDay)),
        .init(id: UUID(), name: "4Four", lastUpdate: Date().addingTimeInterval(-180 * oneDay))
    ]

    struct MigratePreview: View {
        let step: MigrateView.Model.Step

        let profiles: [MigratableProfile]

        let statuses: [UUID: MigrationStatus]

        @State
        private var excluded: Set<UUID> = []

#if os(iOS)
        private let style: MigrateView.Style = .section
#else
        private let style: MigrateView.Style = .table
#endif

        var body: some View {
            Form {
                MigrateView.ContentView(
                    style: style,
                    step: step,
                    profiles: profiles,
                    excluded: $excluded,
                    statuses: statuses
                )
            }
            .navigationTitle("Migrate")
            .themeNavigationStack()
        }
    }
}
