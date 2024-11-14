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

    @Environment(\.dismiss)
    private var dismiss

    let style: Style

    @ObservedObject
    var profileManager: ProfileManager

    @State
    private var model = Model()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        Form {
            ContentView(
                style: style,
                step: model.step,
                profiles: model.visibleProfiles,
                excluded: $model.excluded,
                statuses: model.statuses
            )
            .disabled(model.step != .fetched)
        }
        .themeForm()
        .themeProgress(if: model.step == .fetching)
        .themeEmptyContent(if: model.step == .fetched && model.profiles.isEmpty, message: "Nothing to migrate")
        .themeAnimation(on: model, category: .profiles)
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
            Button(itemTitle(at: model.step)) {
                Task {
                    await itemPerform(at: model.step)
                }
            }
            .disabled(!itemEnabled(at: model.step))
        }
    }
}

private extension MigrateView {
    func itemTitle(at step: Model.Step) -> String {
        switch step {
        case .initial, .fetching, .fetched:
            return "Proceed"

        case .migrating, .migrated:
            return "Import"

        case .importing, .imported:
            return "Done"
        }
    }

    func itemEnabled(at step: Model.Step) -> Bool {
        switch step {
        case .initial, .fetching, .migrating, .importing:
            return false

        case .fetched:
            return !model.profiles.isEmpty

        case .migrated(let profiles):
            return !profiles.isEmpty

        case .imported:
            return true
        }
    }

    func itemPerform(at step: Model.Step) async {
        switch step {
        case .fetched:
            await migrate()

        case .migrated(let profiles):
            await save(profiles)

        case .imported:
            dismiss()

        default:
            fatalError("No action allowed at step \(step)")
        }
    }

    func fetch() async {
        guard model.step == .initial else {
            return
        }
        do {
            model.step = .fetching
            let migratable = try await migrationManager.fetchMigratableProfiles()
            let knownIDs = Set(profileManager.headers.map(\.id))
            model.profiles = migratable.filter {
                !knownIDs.contains($0.id)
            }
            model.step = .fetched
        } catch {
            pp_log(.App.migration, .error, "Unable to fetch migratable profiles: \(error)")
            errorHandler.handle(error, title: title)
            model.step = .initial
        }
    }

    func migrate() async {
        guard model.step == .fetched else {
            fatalError("Must call fetch() and succeed")
        }
        do {
            model.step = .migrating
            let profiles = try await migrationManager.migrateProfiles(model.profiles, selection: model.selection) {
                model.statuses[$0] = $1
            }
            model.step = .migrated(profiles)
        } catch {
            pp_log(.App.migration, .error, "Unable to migrate profiles: \(error)")
            errorHandler.handle(error, title: title)
        }
    }

    func save(_ profiles: [Profile]) async {
        guard case .migrated(let profiles) = model.step, !profiles.isEmpty else {
            fatalError("Must call migrate() and succeed with non-empty profiles")
        }
        model.step = .importing
        model.statuses.forEach {
            if model.statuses[$0.key] == .failed {
                model.statuses[$0.key] = .excluded
            }
        }
        await migrationManager.importProfiles(profiles, into: profileManager) {
            model.statuses[$0] = $1
        }
        model.step = .imported
    }
}
