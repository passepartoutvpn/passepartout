// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

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
        .navigationTitle(Strings.Views.Profile.SendTv.title)
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
