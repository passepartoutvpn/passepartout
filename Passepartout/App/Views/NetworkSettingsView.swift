//
//  NetworkSettingsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
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

import PassepartoutLibrary
import SwiftUI

struct NetworkSettingsView: View {
    @ObservedObject private var currentProfile: ObservableProfile

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
}

// MARK: -

// MARK: Gateway

private extension NetworkSettingsView {
    var gatewayView: some View {
        Section {
            Toggle(L10n.Global.Strings.automatic, isOn: $settings.isAutomaticGateway.themeAnimation())

            if !settings.isAutomaticGateway {
                Toggle(Unlocalized.Network.ipv4, isOn: $settings.gateway.isDefaultIPv4)
                Toggle(Unlocalized.Network.ipv6, isOn: $settings.gateway.isDefaultIPv6)
            }
        } header: {
            Text(L10n.NetworkSettings.Gateway.title)
        }
    }
}

// MARK: DNS

private extension NetworkSettingsView {

    @ViewBuilder
    var dnsView: some View {
        Section {
            Toggle(L10n.Global.Strings.automatic, isOn: $settings.isAutomaticDNS.themeAnimation())

            if !settings.isAutomaticDNS {
                themeTextPicker(
                    L10n.Global.Strings.configuration,
                    selection: $settings.dns.configurationType,
                    values: Network.DNSSettings.availableConfigurationTypes(forVPNProtocol: vpnProtocol),
                    description: \.localizedDescription
                )

                switch settings.dns.configurationType {
                case .plain:
                    EmptyView()

                case .https:
                    dnsManualHTTPSRow

                case .tls:
                    dnsManualTLSRow

                case .disabled:
                    EmptyView()
                }
            }
        } header: {
            Text(Unlocalized.Network.dns)
        }
        if !settings.isAutomaticDNS && settings.dns.configurationType != .disabled {
            dnsManualServers
            dnsManualDomainRow
            dnsManualSearchDomains
        }
    }

    var dnsManualHTTPSRow: some View {
        TextField(Unlocalized.Placeholders.dohURL, text: $settings.dns.dnsHTTPSURL.toString())
            .themeValidURL(settings.dns.dnsHTTPSURL?.absoluteString)
    }

    var dnsManualTLSRow: some View {
        TextField(Unlocalized.Placeholders.dotServerName, text: $settings.dns.dnsTLSServerName ?? "")
            .themeValidDNSOverTLSServerName(settings.dns.dnsTLSServerName)
    }

    var dnsManualServers: some View {
        Section {
            EditableTextList(
                elements: $settings.dns.dnsServers ?? [],
                allowsDuplicates: false,
                mapping: mapNotEmpty
            ) {
                TextField(
                    Unlocalized.Placeholders.dnsAddress,
                    text: $0.text,
                    onEditingChanged: $0.onEditingChanged,
                    onCommit: $0.onCommit
                ).themeValidIPAddress($0.text.wrappedValue)
            } addLabel: {
                Text(L10n.NetworkSettings.Items.AddDnsServer.caption)
            } commitLabel: {
                Text(L10n.Global.Strings.add)
            }
        }
    }

    var dnsManualDomainRow: some View {
        TextField(L10n.Global.Strings.domain, text: $settings.dns.dnsDomain ?? "")
            .themeValidDomainName(settings.dns.dnsDomain)
    }

    var dnsManualSearchDomains: some View {
        Section {
            EditableTextList(
                elements: $settings.dns.dnsSearchDomains ?? [],
                allowsDuplicates: false,
                mapping: mapNotEmpty
            ) {
                TextField(
                    Unlocalized.Placeholders.dnsDomain,
                    text: $0.text,
                    onEditingChanged: $0.onEditingChanged,
                    onCommit: $0.onCommit
                ).themeValidDomainName($0.text.wrappedValue)
            } addLabel: {
                Text(L10n.NetworkSettings.Items.AddDnsDomain.caption)
            } commitLabel: {
                Text(L10n.Global.Strings.add)
            }
        }
    }
}

// MARK: Proxy

private extension NetworkSettingsView {

    @ViewBuilder
    var proxyView: some View {
        Section {
            Toggle(L10n.Global.Strings.automatic, isOn: $settings.isAutomaticProxy.themeAnimation())

            if !settings.isAutomaticProxy {
                themeTextPicker(
                    L10n.Global.Strings.configuration,
                    selection: $settings.proxy.configurationType,
                    values: Network.ProxySettings.availableConfigurationTypes,
                    description: \.localizedDescription
                )

                switch settings.proxy.configurationType {
                case .manual:
                    TextField(Unlocalized.Placeholders.address, text: $settings.proxy.proxyAddress ?? "")
                        .themeValidIPAddress(settings.proxy.proxyAddress)
                        .withLeadingText(L10n.Global.Strings.address)

                    TextField(Unlocalized.Placeholders.port, text: $settings.proxy.proxyPort.toString())
                        .themeValidSocketPort(settings.proxy.proxyPort?.description)
                        .withLeadingText(L10n.Global.Strings.port)

                case .pac:
                    TextField(Unlocalized.Placeholders.pacURL, text: $settings.proxy.proxyAutoConfigurationURL.toString())
                        .themeValidURL(settings.proxy.proxyAutoConfigurationURL?.absoluteString)

                case .disabled:
                    EmptyView()
                }
            }
        } header: {
            Text(L10n.Global.Strings.proxy)
        }
        if !settings.isAutomaticProxy && settings.proxy.configurationType == .manual {
            proxyManualBypassDomains
        }
    }

    var proxyManualBypassDomains: some View {
        Section {
            EditableTextList(
                elements: $settings.proxy.proxyBypassDomains ?? [],
                allowsDuplicates: false,
                mapping: mapNotEmpty
            ) {
                TextField(
                    Unlocalized.Placeholders.proxyBypassDomain,
                    text: $0.text,
                    onEditingChanged: $0.onEditingChanged,
                    onCommit: $0.onCommit
                ).themeValidWildcardDomainName($0.text.wrappedValue)
            } addLabel: {
                Text(L10n.NetworkSettings.Items.AddProxyBypass.caption)
                } commitLabel: {
                    Text(L10n.Global.Strings.add)
            }
        }
    }
}

// MARK: MTU

private extension NetworkSettingsView {
    var mtuView: some View {
        Section {
            Toggle(L10n.Global.Strings.automatic, isOn: $settings.isAutomaticMTU.themeAnimation())

            if !settings.isAutomaticMTU {
                themeTextPicker(
                    L10n.Global.Strings.bytes,
                    selection: $settings.mtu.mtuBytes,
                    values: Network.MTUSettings.availableBytes,
                    description: { $0.localizedDescription(style: .mtu) }
                )
            }
        } header: {
            Text(Unlocalized.Network.mtu)
        }
    }
}

// MARK: Global

private extension NetworkSettingsView {
    var vpnProtocol: VPNProtocolType {
        currentProfile.value.currentVPNProtocol
    }

//    EditButton()
//        .disabled(!isAnythingManual)

    var isAnythingManual: Bool {
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

    func mapNotEmpty(elements: [IdentifiableString]) -> [IdentifiableString] {
        elements
            .filter { !$0.string.isEmpty }
    }
}
