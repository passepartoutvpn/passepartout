//
//  MigrateView+Table.swift
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
import SwiftUI

extension MigrateView {
    struct TableView: View {
        let step: Model.Step

        let profiles: [MigratableProfile]

        @Binding
        var statuses: [UUID: MigrationStatus]

        var body: some View {
            Table(profiles) {
                TableColumn(Strings.Global.name) {
                    Text($0.name)
                        .foregroundStyle(statuses.style(for: $0.id))
                }
                TableColumn(Strings.Global.lastUpdate) {
                    Text($0.timestamp)
                        .foregroundStyle(statuses.style(for: $0.id))
                }
                TableColumn("") {
                    ControlView(
                        step: step,
                        isIncluded: isIncludedBinding(for: $0.id),
                        status: statuses[$0.id]
                    )
                    .environmentObject(theme)
                }
            }
        }
    }
}

private extension MigrateView.TableView {
    func isIncludedBinding(for profileId: UUID) -> Binding<Bool> {
        Binding {
            statuses[profileId] != .excluded
        } set: {
            if $0 {
                statuses.removeValue(forKey: profileId)
            } else {
                statuses[profileId] = .excluded
            }
        }
    }
}

private extension MigrateView.TableView {
    struct ControlView: View {
        let step: MigrateView.Model.Step

        @Binding
        var isIncluded: Bool

        let status: MigrationStatus?

        var body: some View {
            switch step {
            case .initial, .fetching, .fetched:
                Toggle("", isOn: $isIncluded)
                    .labelsHidden()

            default:
                statusView
            }
        }

        @ViewBuilder
        var statusView: some View {
            switch status {
            case .excluded:
                Text("--")

            case .pending:
                ThemeImage(.progress)

            case .migrated, .imported:
                ThemeImage(.marked)

            case .failed:
                ThemeImage(.failure)

            case .none:
                EmptyView()
            }
        }
    }
}

private extension MigratableProfile {
    var timestamp: String {
        lastUpdate?.localizedDescription(style: .timestamp) ?? ""
    }
}
