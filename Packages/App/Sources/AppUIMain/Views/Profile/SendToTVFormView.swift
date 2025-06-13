//
//  SendToTVView.swift
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

import SwiftUI

struct SendToTVFormView: View {

    @Binding
    var addressPort: HTTPAddressPort

    var passcode: Binding<String>?

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
            ThemeTextField(Strings.Global.Nouns.address, text: $addressPort.address, placeholder: Strings.Unlocalized.Placeholders.ipAddress(forFamily: .v4))
#if os(iOS)
                .keyboardType(.numbersAndPunctuation)
#endif
            ThemeTextField(Strings.Global.Nouns.port, text: $addressPort.port, placeholder: Strings.Unlocalized.Placeholders.webUploaderPort)
            Text(Strings.Unlocalized.url)
                .themeTrailingValue(addressPort.urlDescription)
        }
        .themeSection(footer: Strings.Views.Profile.SendTv.Form.message(
            Strings.Global.Nouns.profiles,
            Strings.Views.Tv.Profiles.importLocal,
            Strings.Unlocalized.appleTV
        ))
    }

    var passcodeSection: some View {
        passcode.map { text in
            Group {
                ThemeTextField(Strings.Global.Nouns.passcode, text: text, placeholder: Strings.Unlocalized.Placeholders.webUploaderPasscode)
            }
            .themeSection()
        }
    }
}

#Preview {
    struct FormPreview: View {

        @State
        private var addressPort = HTTPAddressPort()

        @State
        private var passcode = ""

        var body: some View {
            SendToTVFormView(
                addressPort: $addressPort,
                passcode: $passcode
            )
        }
    }

    return FormPreview()
}
