//
//  DiagnosticsView+OpenVPN.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/11/22.
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

#if !os(tvOS)
import PassepartoutLibrary
import SwiftUI
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

        @State private var isReportingIssue = false

        @State private var isAlertPresented = false

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
            .alert(
                L10n.ReportIssue.Alert.title,
                isPresented: $isAlertPresented,
                presenting: alertType,
                actions: alertActions,
                message: alertMessage
            )
        }
    }
}

// MARK: -

private extension DiagnosticsView.OpenVPNView {
    func alertActions(_ alertType: AlertType) -> some View {
        Button(role: .cancel) {
        } label: {
            Text(L10n.Global.Strings.ok)
        }
    }

    func alertMessage(_ alertType: AlertType) -> some View {
        switch alertType {
        case .emailNotConfigured:
            return Text(L10n.Global.Messages.emailNotConfigured)
        }
    }

    var serverConfigurationSection: some View {
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

    var debugLogSection: some View {
        Section {
            DiagnosticsView.DebugLogGroup(appLogURL: appLogURL, tunnelLogURL: tunnelLogURL)
            Toggle(L10n.Diagnostics.Items.MasksPrivateData.caption, isOn: $vpnManager.masksPrivateData)
        } header: {
            Text(L10n.DebugLog.title)
        } footer: {
            Text(L10n.Diagnostics.Sections.DebugLog.footer)
        }
    }

    var issueReporterSection: some View {
        Section {
            Button(L10n.Diagnostics.Items.ReportIssue.caption, action: presentReportIssue)
        }
    }

    func reportIssueView() -> some View {
        ReportIssueView(
            isPresented: $isReportingIssue,
            vpnProtocol: vpnProtocol,
            messageBody: messageBody,
            logs: logs
        )
    }

    var currentServerConfiguration: OpenVPN.ConfigurationBuilder? {
        guard currentVPNState.vpnStatus == .connected else {
            return nil
        }
        guard let cfg = vpnManager.serverConfiguration(forProtocol: vpnProtocol) as? OpenVPN.Configuration else {
            return nil
        }
        // "withFallbacks: false" for view to hide nil options
        return cfg.builder(withFallbacks: false)
    }

    var messageBody: String {
        var providerMetadata: ProviderMetadata?
        var lastUpdate: Date?
        if let name = providerName {
            providerMetadata = providerManager.provider(withName: name)
            lastUpdate = providerManager.lastUpdate(name, vpnProtocol: vpnProtocol)
        }
        return Unlocalized.Issues.body(
            providerMetadata: providerMetadata,
            lastUpdate: lastUpdate,
            purchasedProductIdentifiers: productManager.purchasedProductIdentifiers
        )
    }

    var logs: [MailComposerView.Attachment] {
        var pairs: [(url: URL, filename: String)] = []
        if let appLogURL {
            pairs.append((appLogURL, Unlocalized.Issues.Filenames.appLog))
        }
        if let tunnelLogURL {
            pairs.append((tunnelLogURL, Unlocalized.Issues.Filenames.tunnelLog))
        }
        return pairs.map {
            let logContent = $0.url.trailingContent(bytes: Unlocalized.Issues.maxLogBytes)
            let attachment = DebugLog(content: logContent).decoratedData()

            return MailComposerView.Attachment(
                data: attachment,
                mimeType: Unlocalized.Issues.Filenames.mime,
                fileName: $0.filename
            )
        }
    }

    var appLogURL: URL? {
        Passepartout.shared.logger.logFile
    }

    var tunnelLogURL: URL? {
        vpnManager.debugLogURL(forProtocol: vpnProtocol)
    }

    var isEligibleForFeedback: Bool {
        productManager.isEligibleForFeedback()
    }
}

// MARK: -

private extension DiagnosticsView.OpenVPNView {
    func presentReportIssue() {
        guard MailComposerView.canSendMail() else {
            openReportIssueMailTo()
            return
        }
        isReportingIssue = true
    }

    func openReportIssueMailTo() {
        let V = Unlocalized.Issues.self
        guard let url = URL.mailto(to: V.recipient, subject: V.subject, body: messageBody) else {
            return
        }
        guard URL.open(url) else {
            alertType = .emailNotConfigured
            isAlertPresented = true
            return
        }
    }
}
#endif
