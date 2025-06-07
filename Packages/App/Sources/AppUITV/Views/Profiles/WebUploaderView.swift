//
//  WebUploaderView.swift
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

struct WebUploaderView: View {

    @ObservedObject
    var uploadManager: UploadManager

    let registry: Registry

    @ObservedObject
    var profileManager: ProfileManager

    @ObservedObject
    var errorHandler: ErrorHandler

    var body: some View {
        VStack {
            if let website = uploadManager.website {
                view(forWebsite: website)
            } else {
                Text(Strings.Views.Tv.WebUploader.toggle)
            }
        }
        .task(handleUploadedFile)
        .onDisappear {
            uploadManager.stop()
        }
    }
}

private extension WebUploaderView {
    func view(forWebsite website: UploadManager.Website) -> some View {
        VStack {
            Text(Strings.Views.Tv.WebUploader.qr)
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

private extension WebUploaderView {

    @Sendable
    func handleUploadedFile() async {
        for await file in uploadManager.files {
            pp_log_g(.App.web, .info, "Uploaded: \(file.name), \(file.contents.count) bytes")
            do {
                let input: ModuleImporterInput = .contents(filename: file.name, data: file.contents)

                // TODO: ###, import encrypted OpenVPN profiles
                var profile = try registry.profile(from: input, passphrase: nil)
                pp_log_g(.App.web, .info, "Import uploaded profile: \(profile)")

                var builder = profile.builder()
                builder.attributes.isAvailableForTV = true
                profile = try builder.tryBuild()
                try await profileManager.save(profile, isLocal: true)

                // upload once
                uploadManager.stop()
            } catch {
                pp_log_g(.App.web, .error, "Unable to import uploaded profile: \(error)")
                errorHandler.handle(error)
            }
        }
    }
}

// MARK: -

#Preview {
    WebUploaderView(
        uploadManager: .forPreviews,
        registry: Registry(),
        profileManager: .forPreviews,
        errorHandler: .default()
    )
    .task {
        try? UploadManager.forPreviews.start()
    }
}
