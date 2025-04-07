//
//  DNSView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

import Combine
import CommonUtils
import Partout
import SwiftUI

struct DNSView: View, ModuleDraftEditing {

    @EnvironmentObject
    private var theme: Theme

    @ObservedObject
    var draft: ModuleDraft<DNSModule.Builder>

    init(draft: ModuleDraft<DNSModule.Builder>, parameters: ModuleViewParameters) {
        self.draft = draft
    }

    var body: some View {
        debugChanges()
        return Group {
            protocolSection
            routingSection
            Group {
                domainSection
                serversSection
                searchDomainsSection
            }
            .labelsHidden()
        }
        .themeManualInput()
        .moduleView(draft: draft)
    }
}

private extension DNSView {
    static let allProtocols: [DNSProtocol] = [
        .cleartext,
        .https,
        .tls
    ]

    var protocolSection: some View {
        Section {
            Picker(Strings.Global.Nouns.protocol, selection: $draft.module.protocolType) {
                ForEach(Self.allProtocols, id: \.self) {
                    Text($0.localizedDescription)
                }
            }
            switch draft.module.protocolType {
            case .cleartext:
                EmptyView()

            case .https:
                ThemeTextField(Strings.Unlocalized.url, text: $draft.module.dohURL, placeholder: Strings.Unlocalized.Placeholders.dohURL)
                    .labelsHidden()

            case .tls:
                ThemeTextField(Strings.Global.Nouns.hostname, text: $draft.module.dotHostname, placeholder: Strings.Unlocalized.Placeholders.dotHostname)
                    .labelsHidden()

            @unknown default:
                EmptyView()
            }
        }
    }

    var routingSection: some View {
        Group {
            Picker(Strings.Modules.Dns.routeThroughVpn, selection: $draft.module.routesThroughVPN) {
                Text(Strings.Global.Nouns.default)
                    .tag(nil as Bool?)
                Text(Strings.Global.Nouns.yes)
                    .tag(true as Bool?)
                Text(Strings.Global.Nouns.no)
                    .tag(false as Bool?)
            }
            .themeRowWithSubtitle(Strings.Modules.Dns.RouteThroughVpn.footer)
        }
        .themeSection(footer: Strings.Modules.Dns.RouteThroughVpn.footer)
    }

    var domainSection: some View {
        Group {
            ThemeTextField(Strings.Global.Nouns.domain, text: $draft.module.domainName ?? "", placeholder: Strings.Unlocalized.Placeholders.hostname)
        }
        .themeSection(header: Strings.Global.Nouns.domain)
    }

    var serversSection: some View {
        theme.listSection(
            Strings.Entities.Dns.servers,
            addTitle: Strings.Modules.Dns.Servers.add,
            originalItems: $draft.module.servers,
            itemLabel: {
                if $0 {
                    Text($1.wrappedValue)
                } else {
                    ThemeTextField("", text: $1, placeholder: Strings.Unlocalized.Placeholders.ipV4DNS)
                }
            }
        )
    }

    var searchDomainsSection: some View {
        theme.listSection(
            Strings.Entities.Dns.searchDomains,
            addTitle: Strings.Modules.Dns.SearchDomains.add,
            originalItems: $draft.module.searchDomains ?? [],
            itemLabel: {
                if $0 {
                    Text($1.wrappedValue)
                } else {
                    ThemeTextField("", text: $1, placeholder: Strings.Unlocalized.Placeholders.hostname)
                }
            }
        )
    }
}

// MARK: - Previews

#Preview {
    var module = DNSModule.Builder()
    module.protocolType = .https
    module.servers = ["1.1.1.1", "2.2.2.2", "3.3.3.3"]
    module.dohURL = "https://doh.com/query"
    module.dotHostname = "tls.com"
    module.domainName = "domain.com"
    module.searchDomains = ["one.com", "two.net", "three.com"]
    return module.preview()
}
