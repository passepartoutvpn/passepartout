//
//  DNSView.swift
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

import Combine
import PassepartoutKit
import SwiftUI
import UtilsLibrary

extension DNSModule.Builder: ModuleViewProviding {
    func moduleView(with editor: ProfileEditor) -> some View {
        DNSView(editor: editor, original: self)
    }
}

private struct DNSView: View {

    @EnvironmentObject
    private var theme: Theme

    @ObservedObject
    private var editor: ProfileEditor

    @Binding
    private var draft: DNSModule.Builder

    init(editor: ProfileEditor, original: DNSModule.Builder) {
        self.editor = editor
        _draft = editor.binding(forModule: original)
    }

    var body: some View {
        debugChanges()
        return Group {
            protocolSection
            Group {
                domainSection
                serversSection
                searchDomainsSection
            }
            .labelsHidden()
        }
        .themeManualInput()
        .asModuleView(with: editor, draft: draft)
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
            Picker(Strings.Global.protocol, selection: $draft.protocolType) {
                ForEach(Self.allProtocols, id: \.self) {
                    Text($0.localizedDescription)
                }
            }
            switch draft.protocolType {
            case .cleartext:
                EmptyView()

            case .https:
                ThemeTextField(Strings.Unlocalized.url, text: $draft.dohURL, placeholder: Strings.Unlocalized.Placeholders.dohURL)
                    .labelsHidden()

            case .tls:
                ThemeTextField(Strings.Global.hostname, text: $draft.dotHostname, placeholder: Strings.Unlocalized.Placeholders.dotHostname)
                    .labelsHidden()
            }
        }
    }

    var domainSection: some View {
        Section {
            ThemeTextField(Strings.Global.domain, text: $draft.domainName ?? "", placeholder: Strings.Unlocalized.Placeholders.hostname)
        } header: {
            Text(Strings.Global.domain)
        }
    }

    var serversSection: some View {
        theme.listSection(
            Strings.Entities.Dns.servers,
            addTitle: Strings.Modules.Dns.Servers.add,
            originalItems: $draft.servers,
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
            originalItems: $draft.searchDomains ?? [],
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
