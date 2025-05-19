//
//  DiagnosticsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/24/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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
import UIAccessibility

struct DiagnosticsView: View {
    struct LogEntry: Identifiable, Equatable {
        let date: Date

        let url: URL

        var id: Date {
            date
        }
    }

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    private var iapManager: IAPManager

    @EnvironmentObject
    private var kvStore: KeyValueManager

    let profileManager: ProfileManager

    let tunnel: ExtendedTunnel

    var availableTunnelLogs: (() async -> [LogEntry])?

    @State
    private var logsPrivateData = false

    @State
    private var tunnelLogs: [LogEntry] = []

    @State
    var isPresentingUnableToEmail = false

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = Constants.shared.formats.timestamp
        return df
    }()

    var body: some View {
        Form {
            if iapManager.isBeta {
                BetaSection()
            }
            liveLogSection
            openVPNSection
            tunnelLogsSection
            if AppCommandLine.contains(.withReportIssue) || iapManager.isEligibleForFeedback {
                reportIssueSection
            }
        }
        .task {
            tunnelLogs = await computedTunnelLogs()
        }
        .themeKeyValue(kvStore, AppPreference.logsPrivateData.key, $logsPrivateData, default: false)
        .themeForm()
        .alert(Strings.Views.Diagnostics.ReportIssue.title, isPresented: $isPresentingUnableToEmail) {
            Button(Strings.Global.Nouns.ok, role: .cancel) {
                isPresentingUnableToEmail = false
            }
        } message: {
            Text(Strings.Views.Diagnostics.Alerts.ReportIssue.email)
        }
    }
}

private extension DiagnosticsView {
    var liveLogSection: some View {
        Group {
            navLink(
                Strings.Views.Diagnostics.Rows.app,
                to: .appLog(title: Strings.Views.Diagnostics.Rows.app)
            )
            navLink(
                Strings.Views.Diagnostics.Rows.tunnel,
                to: .tunnelLog(title: Strings.Views.Diagnostics.Rows.tunnel, url: nil)
            )
            LogsPrivateDataToggle()
        }
        .themeSection(header: Strings.Views.Diagnostics.Sections.live)
    }

    var tunnelLogsSection: some View {
        Group {
            Button(Strings.Views.Diagnostics.Rows.removeTunnelLogs) {
                withAnimation(theme.animation(for: .diagnostics), removeTunnelLogs)
            }
            .disabled(tunnelLogs.isEmpty)

            ForEach(tunnelLogs, id: \.date, content: logView)
                .onDelete(perform: removeTunnelLogs)
        }
        .themeSection(header: Strings.Views.Diagnostics.Sections.tunnel)
        .themeAnimation(on: tunnelLogs, category: .diagnostics)
    }

    var openVPNSection: some View {
        // FIXME: #1373, diagnostics/logs must be per-tunnel
        tunnel.activeProfiles.first
            .map {
                tunnel.value(
                    forKey: TunnelEnvironmentKeys.OpenVPN.serverConfiguration,
                    ofProfileId: $0.key
                )
                .map { cfg in
                    Group {
                        NavigationLink(Strings.Views.Diagnostics.Openvpn.Rows.serverConfiguration) {
                            OpenVPNView(serverConfiguration: cfg)
                                .navigationTitle(Strings.Views.Diagnostics.Openvpn.Rows.serverConfiguration)
                        }
                    }
                    .themeSection(header: Strings.Unlocalized.openVPN)
                }
            }
    }

    var reportIssueSection: some View {
        Section {
            ReportIssueButton(
                profileManager: profileManager,
                tunnel: tunnel,
                title: Strings.Views.Diagnostics.ReportIssue.title,
                purchasedProducts: iapManager.purchasedProducts,
                isUnableToEmail: $isPresentingUnableToEmail
            )
        }
    }

    func logView(for item: LogEntry) -> some View {
        ThemeRemovableItemRow(isEditing: true) {
            let dateString = dateFormatter.string(from: item.date)
            navLink(dateString, to: .tunnelLog(title: dateString, url: item.url))
        } removeAction: {
            removeTunnelLog(at: item.url)
        }
    }

    func navLink(_ title: String, to value: DiagnosticsRoute) -> some View {
        NavigationLink(title, value: value)
    }
}

private extension DiagnosticsView {
    func computedTunnelLogs() async -> [LogEntry] {
        await (availableTunnelLogs ?? defaultTunnelLogs)()
    }

    func defaultTunnelLogs() async -> [LogEntry] {
        await Task.detached {
            // FIXME: #1373, diagnostics/logs must be per-tunnel
            LocalLogger.FileStrategy()
                .availableLogs(at: BundleConfiguration.urlForTunnelLog)
                .sorted {
                    $0.key > $1.key
                }
                .map {
                    LogEntry(date: $0, url: $1)
                }
        }.value
    }

    func removeTunnelLog(at url: URL) {
        guard let firstIndex = tunnelLogs.firstIndex(where: { $0.url == url }) else {
            return
        }
        try? FileManager.default.removeItem(at: url)
        tunnelLogs.remove(at: firstIndex)
    }

    func removeTunnelLogs(at offsets: IndexSet) {
        offsets.forEach {
            try? FileManager.default.removeItem(at: tunnelLogs[$0].url)
        }
        tunnelLogs.remove(atOffsets: offsets)
    }

    func removeTunnelLogs() {
        // FIXME: #1373, diagnostics/logs must be per-tunnel
        LocalLogger.FileStrategy()
            .purgeLogs(at: BundleConfiguration.urlForTunnelLog)
        Task {
            tunnelLogs = await computedTunnelLogs()
        }
    }
}

#Preview {
    DiagnosticsView(profileManager: .forPreviews, tunnel: .forPreviews) {
        [
            .init(date: Date(), url: URL(string: "http://one.com")!),
            .init(date: Date().addingTimeInterval(-60), url: URL(string: "http://two.com")!),
            .init(date: Date().addingTimeInterval(-600), url: URL(string: "http://three.com")!)
        ]
    }
    .withMockEnvironment()
}
