//
//  HTTPProxyView.swift
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

import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct HTTPProxyView: View {

    @EnvironmentObject
    private var theme: Theme

    @ObservedObject
    private var editor: ProfileEditor

    @Binding
    private var draft: HTTPProxyModule.Builder

    init(editor: ProfileEditor, module: HTTPProxyModule.Builder) {
        self.editor = editor
        _draft = editor.binding(forModule: module)
    }

    var body: some View {
        Group {
            httpSection
            httpsSection
            pacSection
            bypassSection
        }
        .labelsHidden()
        .themeManualInput()
        .moduleView(editor: editor, draft: draft)
    }
}

private extension HTTPProxyView {
    var httpSection: some View {
        Group {
            ThemeTextField(Strings.Global.address, text: $draft.address, placeholder: Strings.Unlocalized.Placeholders.proxyIPv4Address)
            ThemeTextField(Strings.Global.port, text: $draft.port.toString(omittingZero: true), placeholder: Strings.Unlocalized.Placeholders.proxyPort)
        }
        .themeSection(header: Strings.Unlocalized.http)
    }

    var httpsSection: some View {
        Group {
            ThemeTextField(Strings.Global.address, text: $draft.secureAddress, placeholder: Strings.Unlocalized.Placeholders.proxyIPv4Address)
            ThemeTextField(Strings.Global.port, text: $draft.securePort.toString(omittingZero: true), placeholder: Strings.Unlocalized.Placeholders.proxyPort)
        }
        .themeSection(header: Strings.Unlocalized.https)
    }

    var pacSection: some View {
        Group {
            ThemeTextField(Strings.Unlocalized.url, text: $draft.pacURLString, placeholder: Strings.Unlocalized.Placeholders.pacURL)
        }
        .themeSection(header: Strings.Unlocalized.pac)
    }

    @ViewBuilder
    var bypassSection: some View {
        theme.listSection(
            Strings.Entities.HttpProxy.bypassDomains,
            addTitle: Strings.Modules.HttpProxy.BypassDomains.add,
            originalItems: $draft.bypassDomains,
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

#Preview {
    var module = HTTPProxyModule.Builder()
    module.address = "10.10.10.10"
    module.port = 1080
    module.secureAddress = "20.20.20.20"
    module.securePort = 8080
    module.pacURLString = "http://proxy-pac.url"
    module.bypassDomains = ["bypass-one.com", "two-bypass.net"]
    return module.preview()
}
