//
//  NetworkSettingsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import PassepartoutCore

extension Profile.NetworkSettings: CopySavingModel {
}

struct NetworkSettingsView: View {
    @ObservedObject private var currentProfile: ObservableProfile

    private var vpnProtocol: VPNProtocolType {
        currentProfile.value.currentVPNProtocol
    }

    @State private var settings = Profile.NetworkSettings()
    
    init(currentProfile: ObservableProfile) {
        self.currentProfile = currentProfile
    }

    var body: some View {
        debugChanges()
        return List {
            if vpnProtocol.supportsGateway {
                gatewayView
            }
            if vpnProtocol.supportsDNS {
                dnsView
            }
            if vpnProtocol.supportsProxy {
                proxyView
            }
            if vpnProtocol.supportsMTU {
                mtuView
            }
        }.navigationTitle(L10n.NetworkSettings.title)
        .toolbar {
            CopySavingButton(
                original: $currentProfile.value.networkSettings,
                copy: $settings,
                mapping: \.stripped,
                label: themeSaveButtonLabel
            )
        }
    }
    
//    EditButton()
//        .disabled(!isAnythingManual)

    private var isAnythingManual: Bool {
//        if settings.gateway.choice == .manual {
//            return true
//        }
        if settings.dns.choice == .manual {
            return true
        }
        if settings.proxy.choice == .manual {
            return true
        }
//        if settings.mtu.choice == .manual {
//            return true
//        }
        return false
    }
    
    private func mapNotEmpty(elements: [IdentifiableString]) -> [IdentifiableString] {
        elements
            .filter { !$0.string.isEmpty }
    }
}

// MARK: Gateway

extension NetworkSettingsView {
    private var gatewayView: some View {
        Section(
            header: Text(L10n.NetworkSettings.Gateway.title)
        ) {
            Toggle(L10n.Global.Strings.automatic, isOn: $settings.isAutomaticGateway.animation())

            if !settings.isAutomaticGateway {
                Toggle(Unlocalized.Network.ipv4, isOn: $settings.gateway.isDefaultIPv4)
                Toggle(Unlocalized.Network.ipv6, isOn: $settings.gateway.isDefaultIPv6)
            }
        }
    }
}

// MARK: DNS

extension NetworkSettingsView {
    
    @ViewBuilder
    private var dnsView: some View {
        Section(
            header: Text(Unlocalized.Network.dns)
        ) {
            Toggle(L10n.Global.Strings.automatic, isOn: $settings.isAutomaticDNS.animation())

            if !settings.isAutomaticDNS {
                Toggle(L10n.Global.Strings.enabled, isOn: $settings.dns.isDNSEnabled.animation())

                if settings.dns.isDNSEnabled {
                    themeTextPicker(
                        L10n.Global.Strings.protocol,
                        selection: $settings.dns.dnsProtocol,
                        values: Network.DNSSettings.availableProtocols(forVPNProtocol: vpnProtocol),
                        description: \.localizedDescription
                    )
                    switch settings.dns.dnsProtocol {
                    case .plain:
                        EmptyView()

                    case .https:
                        dnsManualHTTPSRow

                    case .tls:
                        dnsManualTLSRow
                    }
                }
            }
        }
        if !settings.isAutomaticDNS && settings.dns.isDNSEnabled {
            dnsManualServers
            dnsManualDomains
        }
    }
    
    private var dnsManualHTTPSRow: some View {
        TextField(Unlocalized.Placeholders.dohURL, text: $settings.dns.dnsHTTPSURL.toString())
            .themeURL(settings.dns.dnsHTTPSURL?.absoluteString)
    }

    private var dnsManualTLSRow: some View {
        TextField(Unlocalized.Placeholders.dotServerName, text: $settings.dns.dnsTLSServerName ?? "")
            .themeDomainName(settings.dns.dnsTLSServerName)
    }

    private var dnsManualServers: some View {
        Section {
            EditableTextList(
                elements: $settings.dns.dnsServers,
                allowsDuplicates: false,
                mapping: mapNotEmpty
            ) {
                TextField(
                    Unlocalized.Placeholders.dnsAddress,
                    text: $0.text,
                    onEditingChanged: $0.onEditingChanged,
                    onCommit: $0.onCommit
                ).themeIPAddress($0.text.wrappedValue)
            } addLabel: {
                Text(L10n.NetworkSettings.Items.AddDnsServer.caption)
//            } commitLabel: {
//                Text(L10n.Global.Strings.add)
            }
        }
    }
    
    private var dnsManualDomains: some View {
        Section {
            EditableTextList(
                elements: $settings.dns.dnsSearchDomains,
                allowsDuplicates: false,
                mapping: mapNotEmpty
            ) {
                TextField(
                    Unlocalized.Placeholders.dnsDomain,
                    text: $0.text,
                    onEditingChanged: $0.onEditingChanged,
                    onCommit: $0.onCommit
                ).themeDomainName($0.text.wrappedValue)
            } addLabel: {
                Text(L10n.NetworkSettings.Items.AddDnsDomain.caption)
//            } commitLabel: {
//                Text(L10n.Global.Strings.add)
            }
        }
    }
}

// MARK: Proxy

extension NetworkSettingsView {
    
    @ViewBuilder
    private var proxyView: some View {
        Section(
            header: Text(L10n.Global.Strings.proxy)
        ) {
            Toggle(L10n.Global.Strings.automatic, isOn: $settings.isAutomaticProxy.animation())

            if !settings.isAutomaticProxy {
                themeTextPicker(
                    // FIXME: l10n, refactor string id to "global.strings.configuration"
                    L10n.Profile.Sections.Configuration.header,
                    selection: $settings.proxy.configurationType,
                    values: Network.ProxySettings.availableConfigurationTypes,
                    description: \.localizedDescription
                )

                switch settings.proxy.configurationType {
                case .manual:
                    TextField(Unlocalized.Placeholders.address, text: $settings.proxy.proxyAddress ?? "")
                        .themeIPAddress(settings.proxy.proxyAddress)
                        .withLeadingText(L10n.Global.Strings.address)

                    TextField(Unlocalized.Placeholders.port, text: $settings.proxy.proxyPort.toString())
                        .themeSocketPort()
                        .withLeadingText(L10n.Global.Strings.port)

                case .pac:
                    TextField(Unlocalized.Placeholders.pacURL, text: $settings.proxy.proxyAutoConfigurationURL.toString())
                        .themeURL(settings.proxy.proxyAutoConfigurationURL?.absoluteString)

                case .disabled:
                    EmptyView()
                }
            }
        }
        if !settings.isAutomaticProxy && settings.proxy.configurationType == .manual {
            proxyManualBypassDomains
        }
    }
    
    private var proxyManualBypassDomains: some View {
        Section {
            EditableTextList(
                elements: $settings.proxy.proxyBypassDomains,
                allowsDuplicates: false,
                mapping: mapNotEmpty
            ) {
                TextField(
                    Unlocalized.Placeholders.proxyBypassDomain,
                    text: $0.text,
                    onEditingChanged: $0.onEditingChanged,
                    onCommit: $0.onCommit
                ).themeDomainName($0.text.wrappedValue)
            } addLabel: {
                Text(L10n.NetworkSettings.Items.AddProxyBypass.caption)
//                } commitLabel: {
//                    Text(L10n.Global.Strings.add)
            }
        }
    }
}

// MARK: MTU

extension NetworkSettingsView {
    private var mtuView: some View {
        Section(
            header: Text(Unlocalized.Network.mtu)
        ) {
            Toggle(L10n.Global.Strings.automatic, isOn: $settings.isAutomaticMTU.animation())
            
            if !settings.isAutomaticMTU {
                themeTextPicker(
                    L10n.Global.Strings.bytes,
                    selection: $settings.mtu.mtuBytes,
                    values: Network.MTUSettings.availableBytes,
                    description: \.localizedDescriptionAsMTU
                )
            }
        }
    }
}
