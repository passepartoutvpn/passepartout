//
//  OpenVPNView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

struct OpenVPNView: View, ModuleDraftEditing {

    @Environment(\.navigationPath)
    private var path

    @ObservedObject
    var editor: ProfileEditor

    let module: OpenVPNModule.Builder

    let impl: OpenVPNModule.Implementation?

    private let isServerPushed: Bool

    @State
    private var isImporting = false

    @State
    private var importURL: URL?

    @State
    private var importPassphrase: String?

    @State
    private var requiresPassphrase = false

    @State
    private var paywallReason: PaywallReason?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    init(serverConfiguration: OpenVPN.Configuration) {
        let module = OpenVPNModule.Builder(configurationBuilder: serverConfiguration.builder())
        let editor = ProfileEditor(modules: [module])
        assert(module.configurationBuilder != nil, "isServerPushed must imply module.configurationBuilder != nil")

        self.editor = editor
        self.module = module
        impl = nil
        isServerPushed = true
    }

    init(editor: ProfileEditor, module: OpenVPNModule.Builder, impl: OpenVPNModule.Implementation?) {
        self.editor = editor
        self.module = module
        self.impl = impl
        isServerPushed = false
    }

    var body: some View {
        contentView
            .moduleView(editor: editor, draft: draft.wrappedValue)
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.item],
                onCompletion: importConfiguration
            )
            .modifier(PaywallModifier(reason: $paywallReason))
            .navigationDestination(for: Subroute.self, destination: destination)
            .themeAnimation(on: providerId.wrappedValue, category: .modules)
            .withErrorHandler(errorHandler)
    }
}

// MARK: - Content

private extension OpenVPNView {

    @ViewBuilder
    var contentView: some View {
        if let configuration = draft.wrappedValue.configurationBuilder {
            ConfigurationView(
                isServerPushed: isServerPushed,
                configuration: configuration,
                credentialsRoute: Subroute.credentials
            )
        } else {
            importView
                .modifier(providerModifier)
        }
    }

    @ViewBuilder
    var importView: some View {
        if providerId.wrappedValue == nil {
            Button(Strings.Modules.General.Rows.importFromFile.withTrailingDots) {
                isImporting = true
            }
            .alert(
                module.moduleType.localizedDescription,
                isPresented: $requiresPassphrase,
                presenting: importURL,
                actions: { url in
                    SecureField(
                        Strings.Placeholders.secret,
                        text: $importPassphrase ?? ""
                    )
                    Button(Strings.Alerts.Import.Passphrase.ok) {
                        importConfiguration(from: .success(url))
                    }
                    Button(Strings.Global.Actions.cancel, role: .cancel) {
                        isImporting = false
                    }
                },
                message: {
                    Text(Strings.Alerts.Import.Passphrase.message($0.lastPathComponent))
                }
            )
        }
    }

    var providerModifier: some ViewModifier {
        VPNProviderContentModifier(
            providerId: providerId,
            selectedEntity: providerEntity,
            paywallReason: $paywallReason,
            entityDestination: Subroute.providerServer,
            providerRows: {
                moduleGroup(for: providerAccountRows)
            }
        )
    }

    var providerId: Binding<ProviderID?> {
        editor.binding(forProviderOf: module.id)
    }

    var providerEntity: Binding<VPNEntity<OpenVPN.Configuration>?> {
        editor.binding(forProviderEntityOf: module.id)
    }

    var providerAccountRows: [ModuleRow]? {
        [.push(caption: Strings.Modules.Openvpn.credentials, route: HashableRoute(Subroute.credentials))]
    }
}

private extension OpenVPNView {
    func onSelectServer(server: VPNServer, preset: VPNPreset<OpenVPN.Configuration>) {
        providerEntity.wrappedValue = VPNEntity(server: server, preset: preset)
        path.wrappedValue.removeLast()
    }

    func importConfiguration(from result: Result<URL, Error>) {
        do {
            let url = try result.get()
            guard url.startAccessingSecurityScopedResource() else {
                throw AppError.permissionDenied
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            importURL = url

            guard let impl else {
                fatalError("Requires OpenVPNModule implementation")
            }
            guard let parser = impl.importer as? StandardOpenVPNParser else {
                fatalError("OpenVPNModule importer should be StandardOpenVPNParser")
            }
            let parsed = try parser.parsed(fromURL: url, passphrase: importPassphrase)

            draft.wrappedValue.configurationBuilder = parsed.configuration.builder()
        } catch StandardOpenVPNParserError.encryptionPassphrase,
                StandardOpenVPNParserError.unableToDecrypt {
            Task {
                // XXX: re-present same alert after artificial delay
                try? await Task.sleep(for: .milliseconds(500))
                importPassphrase = nil
                requiresPassphrase = true
            }
        } catch {
            pp_log(.app, .error, "Unable to import OpenVPN configuration: \(error)")
            errorHandler.handle(
                (error as? StandardOpenVPNParserError)?.asPassepartoutError ?? error,
                title: module.moduleType.localizedDescription
            )
        }
    }
}

// MARK: - Destinations

private extension OpenVPNView {
    enum Subroute: Hashable {
        case providerServer

        case credentials
    }

    @ViewBuilder
    func destination(for route: Subroute) -> some View {
        switch route {
        case .providerServer:
            providerId.wrappedValue.map {
                VPNProviderServerView(
                    moduleId: module.id,
                    providerId: $0,
                    configurationType: OpenVPN.Configuration.self,
                    selectedEntity: providerEntity.wrappedValue,
                    filtersWithSelection: true,
                    onSelect: onSelectServer
                )
            }

        case .credentials:
            Form {
                OpenVPNCredentialsView(
                    providerId: draft.providerId.wrappedValue,
                    isInteractive: draft.isInteractive,
                    credentials: draft.credentials
                )
            }
            .navigationTitle(Strings.Modules.Openvpn.credentials)
            .themeForm()
            .themeAnimation(on: draft.wrappedValue.isInteractive, category: .modules)
        }
    }
}

// MARK: - Previews

// swiftlint: disable force_try
#Preview {
    var builder = OpenVPN.Configuration.Builder(withFallbacks: true)
    builder.noPullMask = [.proxy]
    builder.authUserPass = true
    builder.remotes = [
        .init(rawValue: "2.2.2.2:UDP:2222")!,
        .init(rawValue: "6.6.6.6:UDP:6666")!,
        .init(rawValue: "12.12.12.12:TCP:21212")!,
        .init(rawValue: "12:12:12:12:20:20:20:20:TCP6:21212")!
    ]
    builder.ipv4 = IPSettings(subnet: try! .init("5.5.5.5", 24))
        .including(routes: [
            .init(defaultWithGateway: .ip("120.1.1.1", .v4)),
            .init(.init(rawValue: "55.10.20.30/32"), nil)
        ])
        .excluding(routes: [
            .init(.init(rawValue: "88.40.30.30/32"), nil),
            .init(.init(rawValue: "60.60.60.60/32"), .ip("127.0.0.1", .v4))
        ])
    builder.ipv6 = IPSettings(subnet: try! .init("::5", 24))
        .including(routes: [
            .init(defaultWithGateway: .ip("120::1:1:1", .v6)),
            .init(.init(rawValue: "55:10:20::30/128"), nil),
            .init(.init(rawValue: "60:60:60::60/128"), .ip("::2", .v6))
        ])
        .excluding(routes: [
            .init(.init(rawValue: "88:40:30::30/32"), nil)
        ])
    builder.routingPolicies = [.IPv4, .IPv6]
    builder.dnsServers = ["1.2.3.4", "4.5.6.7"]
    builder.dnsDomain = "domain.com"
    builder.searchDomains = ["search1.com", "search2.com"]
    builder.httpProxy = try! .init("10.10.10.10", 1080)
    builder.httpsProxy = try! .init("10.10.10.10", 8080)
    builder.proxyAutoConfigurationURL = URL(string: "https://hello.pac")!
    builder.proxyBypassDomains = ["bypass1.com", "bypass2.com"]
    builder.xorMethod = .xormask(mask: .init(Data(hex: "1234")))
    builder.ca = .init(mockPem: "ca-certificate")
    builder.clientCertificate = .init(mockPem: "client-certificate")
    builder.clientKey = .init(mockPem: "client-key")
    builder.tlsWrap = .init(strategy: .auth, key: .init(biData: Data(count: 256)))
    builder.keepAliveInterval = 10.0
    builder.renegotiatesAfter = 60.0
    builder.randomizeEndpoint = true
    builder.randomizeHostnames = true

    let module = OpenVPNModule.Builder(configurationBuilder: builder)
    return module.preview(title: "OpenVPN")
}
// swiftlint: enable force_try

private extension OpenVPN.CryptoContainer {
    init(mockPem: String) {
        self.init(pem: """
-----BEGIN CERTIFICATE-----
\(mockPem)
-----END CERTIFICATE-----
""")
    }
}
