//
//  DiagnosticsView+OpenVPN.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/11/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import SwiftUI
import PassepartoutLibrary
import TunnelKitOpenVPN

extension DiagnosticsView {
    struct OpenVPNView: View {
        enum AlertType: Int, Identifiable {
            case emailNotConfigured

            var id: Int {
                return rawValue
            }
        }

        @ObservedObject private var providerManager: ProviderManager

        @ObservedObject private var vpnManager: VPNManager

        @ObservedObject private var currentVPNState: ObservableVPNState

        @ObservedObject private var productManager: ProductManager

        private let providerName: ProviderName?

        private var isEligibleForFeedback: Bool {
            productManager.isEligibleForFeedback()
        }

        @State private var isReportingIssue = false

        @State private var alertType: AlertType?

        private let vpnProtocol: VPNProtocolType = .openVPN

        init(providerName: ProviderName?) {
            providerManager = .shared
            vpnManager = .shared
            currentVPNState = .shared
            productManager = .shared
            self.providerName = providerName
        }

        var body: some View {
            List {
                serverConfigurationSection
                debugLogSection

                // eligibility: to report a connectivity issue
                if isEligibleForFeedback {
                    issueReporterSection
                }
            }.sheet(isPresented: $isReportingIssue, content: reportIssueView)
            .alert(item: $alertType, content: presentedAlert)
        }

        private func presentedAlert(_ alertType: AlertType) -> Alert {
            switch alertType {
            case .emailNotConfigured:
                return Alert(
                    title: Text(L10n.ReportIssue.Alert.title),
                    message: Text(L10n.Global.Messages.emailNotConfigured),
                    dismissButton: .cancel(Text(L10n.Global.Strings.ok))
                )
            }
        }

        private var serverConfigurationSection: some View {
            Section {
                let cfg = currentServerConfiguration
                NavigationLink(L10n.Diagnostics.Items.ServerConfiguration.caption) {
                    cfg.map {
                        EndpointAdvancedView.OpenVPNView(
                            builder: .constant($0),
                            isReadonly: true,
                            isServerPushed: true
                        ).navigationTitle(L10n.Diagnostics.Items.ServerConfiguration.caption)
                    }
                }.disabled(cfg == nil)
            }
        }

        private var debugLogSection: some View {
            Section {
                DebugLogSection(appLogURL: appLogURL, tunnelLogURL: tunnelLogURL)
                Toggle(L10n.Diagnostics.Items.MasksPrivateData.caption, isOn: $vpnManager.masksPrivateData)
            } header: {
                Text(L10n.DebugLog.title)
            } footer: {
                Text(L10n.Diagnostics.Sections.DebugLog.footer)
            }
        }

        private var issueReporterSection: some View {
            Section {
                Button(L10n.Diagnostics.Items.ReportIssue.caption, action: presentReportIssue)
            }
        }

        private func reportIssueView() -> some View {
            let logURL = vpnManager.debugLogURL(forProtocol: vpnProtocol)
            var metadata: ProviderMetadata?
            var lastUpdate: Date?
            if let name = providerName {
                metadata = providerManager.provider(withName: name)
                lastUpdate = providerManager.lastUpdate(name, vpnProtocol: vpnProtocol)
            }

            return ReportIssueView(
                isPresented: $isReportingIssue,
                vpnProtocol: vpnProtocol,
                logURL: logURL,
                providerMetadata: metadata,
                lastUpdate: lastUpdate
            )
        }
    }
}

extension DiagnosticsView.OpenVPNView {
    private var currentServerConfiguration: OpenVPN.ConfigurationBuilder? {
        guard currentVPNState.vpnStatus == .connected else {
            return nil
        }
        guard let cfg = vpnManager.serverConfiguration(forProtocol: vpnProtocol) as? OpenVPN.Configuration else {
            return nil
        }
        // "withFallbacks: false" for view to hide nil options
        return cfg.builder(withFallbacks: false)
    }

    private var appLogURL: URL? {
        LogManager.shared.logFile
    }

    private var tunnelLogURL: URL? {
        vpnManager.debugLogURL(forProtocol: vpnProtocol)
    }
}

extension DiagnosticsView.OpenVPNView {
    private func presentReportIssue() {
        guard MailComposerView.canSendMail() else {
            openReportIssueMailTo()
            return
        }
        isReportingIssue = true
    }

    private func openReportIssueMailTo() {
        let V = Unlocalized.Issues.self
        let body = V.body(V.template, DebugLog(content: "--").decoratedString())

        guard let url = URL.mailto(to: V.recipient, subject: V.subject, body: body) else {
            return
        }
        guard URL.openURL(url) else {
            alertType = .emailNotConfigured
            return
        }
    }
}
