// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import SwiftUI

extension MigrateContentView {
    struct TableView: View {

        @EnvironmentObject
        private var theme: Theme

        let step: MigrateViewStep

        let profiles: [MigratableProfile]

        @Binding
        var statuses: [UUID: MigrationStatus]

        let onDelete: ([MigratableProfile]) -> Void

        let performButton: () -> PerformButton

        var body: some View {
            VStack(spacing: .zero) {
                messageView
                profilesForm
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction, content: performButton)
            }
        }
    }
}

private extension MigrateContentView.TableView {
    var isEmpty: Bool {
        step.isReady && profiles.isEmpty
    }

    var messageView: some View {
        Text(Strings.Views.Migration.Sections.Main.header(Strings.Unlocalized.appName))
            .padding([.top, .leading, .trailing])
    }

    var profilesForm: some View {
        Form {
            Table(profiles) {
                TableColumn(Strings.Global.Nouns.name) {
                    Text($0.name)
                        .foregroundStyle(statuses.style(for: $0.id))
                }
                TableColumn(Strings.Global.Nouns.lastUpdate) {
                    Text($0.timestamp)
                        .foregroundStyle(statuses.style(for: $0.id))
                }
                TableColumn("") {
                    ControlView(
                        step: step,
                        isIncluded: isIncludedBinding(for: $0.id),
                        status: statuses[$0.id]
                    )
                    .environmentObject(theme) // TODO: #873, Table loses environment
                }
                .width(30)
                TableColumn("") { profile in
                    Button {
                        onDelete([profile])
                    } label: {
                        ThemeImage(.editableSectionRemove)
                    }
                    .environmentObject(theme) // TODO: #873, Table loses environment
                }
                .width(20)
            }
            .disabled(!step.canSelect)
        }
        .themeForm()
        .themeEmpty(if: isEmpty, message: Strings.Views.Migration.noProfiles)
    }

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

private extension MigratableProfile {
    var timestamp: String {
        lastUpdate?.localizedDescription(style: .timestamp) ?? ""
    }
}

// MARK: - Subviews

private extension MigrateContentView.TableView {
    struct ControlView: View {
        let step: MigrateViewStep

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
                Text(Strings.Unlocalized.longDash)

            case .pending:
                ThemeImage(.progress)

            case .done:
                ThemeImage(.marked)

            case .failed:
                ThemeImage(.failure)

            case .none:
                EmptyView()
            }
        }
    }
}
