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

struct MigrateContentView<PerformButton>: View where PerformButton: View {
    let style: MigrateView.Style

    let step: MigrateViewStep

    let profiles: [MigratableProfile]

    @Binding
    var statuses: [UUID: MigrationStatus]

    @Binding
    var isEditing: Bool

    let onDelete: ([MigratableProfile]) -> Void

    let performButton: () -> PerformButton

    var body: some View {
        switch style {
        case .list:
            ListView(
                step: step,
                profiles: profiles,
                statuses: $statuses,
                isEditing: $isEditing,
                onDelete: onDelete,
                performButton: performButton
            )

        case .table:
            TableView(
                step: step,
                profiles: profiles,
                statuses: $statuses,
                onDelete: onDelete,
                performButton: performButton
            )
        }
    }
}

extension Optional where Wrapped == MigrationStatus {
    var style: some ShapeStyle {
        self != .excluded ? .primary : .secondary
    }
}

extension Dictionary where Key == UUID, Value == MigrationStatus {
    func style(for profileId: UUID) -> some ShapeStyle {
        self[profileId].style
    }
}

// MARK: - Previews

#Preview("Fetched") {
    PrivatePreviews.MigratePreview(
        step: .fetched(PrivatePreviews.profiles),
        profiles: PrivatePreviews.profiles,
        initialStatuses: [
            PrivatePreviews.profiles[1].id: .excluded,
            PrivatePreviews.profiles[2].id: .excluded
        ]
    )
    .withMockEnvironment()
}

#Preview("Migrated") {
    PrivatePreviews.MigratePreview(
        step: .migrated([]),
        profiles: PrivatePreviews.profiles,
        initialStatuses: [
            PrivatePreviews.profiles[0].id: .excluded,
            PrivatePreviews.profiles[1].id: .pending,
            PrivatePreviews.profiles[2].id: .migrated,
            PrivatePreviews.profiles[3].id: .imported,
            PrivatePreviews.profiles[4].id: .failed
        ]
    )
    .withMockEnvironment()
}

#Preview("Empty") {
    PrivatePreviews.MigratePreview(
        step: .fetched([]),
        profiles: [],
        initialStatuses: [:]
    )
    .withMockEnvironment()
}

private struct PrivatePreviews {
    static let oneDay: TimeInterval = 24 * 60 * 60

    static let profiles: [MigratableProfile] = [
        .init(id: UUID(), name: "1 One", lastUpdate: Date().addingTimeInterval(-oneDay)),
        .init(id: UUID(), name: "2 Two", lastUpdate: Date().addingTimeInterval(-3 * oneDay)),
        .init(id: UUID(), name: "3 Three", lastUpdate: Date().addingTimeInterval(-90 * oneDay)),
        .init(id: UUID(), name: "4 Four", lastUpdate: Date().addingTimeInterval(-180 * oneDay)),
        .init(id: UUID(), name: "5 Five", lastUpdate: Date().addingTimeInterval(-240 * oneDay))
    ]

    struct MigratePreview: View {
        let step: MigrateViewStep

        let profiles: [MigratableProfile]

        let initialStatuses: [UUID: MigrationStatus]

        @State
        private var statuses: [UUID: MigrationStatus] = [:]

        @State
        private var isEditing = false

#if os(iOS)
        private let style: MigrateView.Style = .list
#else
        private let style: MigrateView.Style = .table
#endif

        var body: some View {
            MigrateContentView(
                style: style,
                step: step,
                profiles: profiles,
                statuses: $statuses,
                isEditing: $isEditing,
                onDelete: { _ in },
                performButton: {
                    Button("Item") {}
                }
            )
            .navigationTitle("Migrate")
            .themeNavigationStack()
            .task {
                statuses = initialStatuses
            }
        }
    }
}
