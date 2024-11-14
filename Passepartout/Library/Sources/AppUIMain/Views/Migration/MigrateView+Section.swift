//
//  MigrateView+Section.swift
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
    struct SectionView: View {
        let step: Model.Step

        let profiles: [MigratableProfile]

        @Binding
        var statuses: [UUID: MigrationStatus]

        var body: some View {
            Section {
                ForEach(profiles, id: \.id) {
                    switch step {
                    case .initial, .fetching, .fetched:
                        button(forProfile: $0)

                    default:
                        row(forProfile: $0, status: statuses[$0.id])
                    }
                }
            }
        }
    }
}

private extension MigrateView.SectionView {
    func button(forProfile profile: MigratableProfile) -> some View {
        Button {
            if statuses[profile.id] == .excluded {
                statuses.removeValue(forKey: profile.id)
            } else {
                statuses[profile.id] = .excluded
            }
        } label: {
            row(forProfile: profile, status: nil)
        }
    }

    func row(forProfile profile: MigratableProfile, status: MigrationStatus?) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(profile.name)
                    .font(.headline)

                profile.lastUpdate.map {
                    Text($0.localizedDescription(style: .timestamp))
                        .font(.subheadline)
                }
            }
            Spacer()
            StatusView(isIncluded: statuses[profile.id] != .excluded, status: status)
        }
    }
}

private extension MigrateView.SectionView {
    struct StatusView: View {
        let isIncluded: Bool

        let status: MigrationStatus?

        var body: some View {
            if let status {
                icon(forStatus: status)
            } else if isIncluded {
                ThemeImage(.marked)
            }
        }

        @ViewBuilder
        func icon(forStatus status: MigrationStatus) -> some View {
            switch status {
            case .excluded:
                Text("--")

            case .pending:
                ProgressView()

            case .migrated, .imported:
                ThemeImage(.marked)

            case .failed:
                ThemeImage(.failure)
            }
        }
    }
}
