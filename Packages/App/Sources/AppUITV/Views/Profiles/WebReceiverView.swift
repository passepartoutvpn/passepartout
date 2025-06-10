//
//  WebReceiverView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/5/25.
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

import CommonLibrary
import CommonUtils
import SwiftUI

struct WebReceiverView: View {

    @EnvironmentObject
    private var registryCoder: RegistryCoder

    @ObservedObject
    var webReceiverManager: WebReceiverManager

    let registry: Registry

    @ObservedObject
    var profileManager: ProfileManager

    @ObservedObject
    var errorHandler: ErrorHandler

    var body: some View {
        VStack {
            if let website = webReceiverManager.website {
                view(forWebsite: website)
            } else {
                Text(Strings.Views.Tv.WebReceiver.toggle)
            }
        }
        .task(handleUploadedFile)
        .onDisappear {
            webReceiverManager.stop()
        }
    }
}

private extension WebReceiverView {
    func view(forWebsite website: WebReceiverManager.Website) -> some View {
        VStack {
            Text(Strings.Views.Tv.WebReceiver.qr)
            QRCodeView(text: website.url.absoluteString)
                .frame(width: 400)
                .padding(.vertical)

            VStack {
                Text(website.url.absoluteString)
                    .fontWeight(.bold)

                if let passcode = website.passcode {
                    HStack(spacing: .zero) {
                        Text("\(Strings.Global.Nouns.passcode): ")
                        Text(passcode)
                            .fontWeight(.bold)
                    }
                }
            }
            .font(.title3)

            Spacer()
        }
    }
}

private extension WebReceiverView {

    @Sendable
    func handleUploadedFile() async {
        for await file in webReceiverManager.files {
            pp_log_g(.App.web, .info, "Uploaded: \(file.name), \(file.contents.count) bytes")
            do {
                let input: ProfileImporterInput = .contents(filename: file.name, data: file.contents)

                // TODO: ###, import encrypted OpenVPN profiles
                var profile = try registryCoder.profile(from: input, passphrase: nil)
                pp_log_g(.App.web, .info, "Import uploaded profile: \(profile)")

                var builder = profile.builder()
                builder.attributes.isAvailableForTV = true
                profile = try builder.tryBuild()
                try await profileManager.save(profile, isLocal: true)

                webReceiverManager.renewPasscode()
            } catch {
                pp_log_g(.App.web, .error, "Unable to import uploaded profile: \(error)")
                errorHandler.handle(error)
            }
        }
    }
}

// MARK: -

#Preview {
    WebReceiverView(
        webReceiverManager: .forPreviews,
        registry: Registry(),
        profileManager: .forPreviews,
        errorHandler: .default()
    )
    .task {
        try? WebReceiverManager.forPreviews.start()
    }
}
