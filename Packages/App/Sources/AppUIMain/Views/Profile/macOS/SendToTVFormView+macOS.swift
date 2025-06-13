//
//  SendToTVView+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/8/25.
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

#if os(macOS)

import SwiftUI

struct SendToTVFormView: View {

    @Binding
    var address: String

    @Binding
    var port: String

    @Binding
    var passcode: String

    var body: some View {
        Form {
            urlSection
            passcodeSection
        }
        .themeForm()
        .navigationTitle(Strings.Views.Profile.SendTv.title_compound)
    }
}

private extension SendToTVFormView {
    var urlSection: some View {
        Group {
            ThemeTextField(Strings.Global.Nouns.address, text: $address, placeholder: Strings.Unlocalized.Placeholders.ipAddress(forFamily: .v4))
            ThemeTextField(Strings.Global.Nouns.port, text: $port, placeholder: Strings.Unlocalized.Placeholders.webUploaderPort)
            Text(Strings.Unlocalized.url)
                .themeTrailingValue(currentURLString)
        }
        .themeSection(footer: Strings.Views.Profile.SendTv.Form.message(
            Strings.Global.Nouns.profiles,
            Strings.Views.Tv.Profiles.importLocal,
            Strings.Unlocalized.appleTV
        ))
    }

    var passcodeSection: some View {
        Group {
            ThemeTextField(Strings.Global.Nouns.passcode, text: $passcode, placeholder: Strings.Unlocalized.Placeholders.webUploaderPasscode)
        }
        .themeSection()
    }

    var addressDescription: String {
        !address.isEmpty ? address : "<\(Strings.Global.Nouns.address.lowercased())>"
    }

    var currentURLString: String? {
        guard let port = Int(port) else {
            let portDescription = "<\(Strings.Global.Nouns.port.lowercased())>"
            return "http://\(addressDescription):\(portDescription)"
        }
        guard !address.isEmpty else {
            return "http://\(addressDescription):\(port)"
        }
        return URL(httpAddress: address, port: port)?.absoluteString
    }
}

#Preview {
    struct FormPreview: View {

        @State
        private var address = ""

        @State
        private var port = ""

        @State
        private var passcode = ""

        var body: some View {
            SendToTVFormView(
                address: $address,
                port: $port,
                passcode: $passcode
            )
        }
    }

    return FormPreview()
}

#endif
