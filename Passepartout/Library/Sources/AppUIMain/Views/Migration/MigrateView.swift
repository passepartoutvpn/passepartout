//
//  MigrateView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/13/24.
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
import CommonUtils
import PassepartoutKit
import SwiftUI

// FIXME: ###, migrations UI

struct MigrateView: View {
    enum Style {
        case section

        case table
    }

    @EnvironmentObject
    private var migrationManager: MigrationManager

    let style: Style

    @ObservedObject
    var profileManager: ProfileManager

    @State
    private var isFetching = true

    @State
    private var isMigrating = false

    @State
    private var profiles: [MigratableProfile] = []

    @State
    private var excluded: Set<UUID> = []

    @State
    private var statuses: [UUID: MigrationStatus] = [:]

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        Form {
            Subview(
                style: style,
                profiles: profiles,
                excluded: $excluded,
                statuses: statuses
            )
            .disabled(isMigrating)
        }
        .themeForm()
        .themeProgress(if: isFetching)
        .themeEmptyContent(if: !isFetching && profiles.isEmpty, message: "Nothing to migrate")
        .navigationTitle(title)
        .toolbar(content: toolbarContent)
        .task {
            await fetch()
        }
        .withErrorHandler(errorHandler)
    }
}

private extension MigrateView {
    var title: String {
        Strings.Views.Migrate.title
    }

    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Proceed") {
                Task {
                    await migrate()
                }
            }
        }
    }
}

private extension MigrateView {
    func fetch() async {
        do {
            isFetching = true
            profiles = try await migrationManager.fetchMigratableProfiles()
            isFetching = false
        } catch {
            pp_log(.App.migration, .error, "Unable to fetch migratable profiles: \(error)")
            errorHandler.handle(error, title: title)
            isFetching = false
        }
    }

    func migrate() async {
        do {
            isMigrating = true
            let selection = Set(profiles.map(\.id)).symmetricDifference(excluded)
            let migrated = try await migrationManager.migrateProfiles(profiles, selection: selection) {
                statuses[$0] = $1
            }
            print(">>> Migrated: \(migrated.count)")
            _ = migrated
            // FIXME: ###, import migrated
        } catch {
            pp_log(.App.migration, .error, "Unable to migrate profiles: \(error)")
            errorHandler.handle(error, title: title)
        }
    }
}

// MARK: -

private extension MigrateView {
    struct Subview: View {
        let style: Style

        let profiles: [MigratableProfile]

        @Binding
        var excluded: Set<UUID>

        let statuses: [UUID: MigrationStatus]

        var body: some View {
            switch style {
            case .section:
                MigrateView.SectionView(
                    profiles: sortedProfiles,
                    excluded: $excluded,
                    statuses: statuses
                )

            case .table:
                MigrateView.TableView(
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

#Preview("Before") {
    PrivatePreviews.MigratePreview(
        profiles: PrivatePreviews.profiles,
        statuses: [:]
    )
    .withMockEnvironment()
}

#Preview("After") {
    PrivatePreviews.MigratePreview(
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
                MigrateView.Subview(
                    style: style,
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
