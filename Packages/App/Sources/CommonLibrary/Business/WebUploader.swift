// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonUtils
import Foundation

public final class WebUploader: ObservableObject, Sendable {
    private let registryCoder: RegistryCoder

    private let profile: Profile

    private let strategy: WebUploaderStrategy

    public init(
        registryCoder: RegistryCoder,
        profile: Profile,
        strategy: WebUploaderStrategy
    ) {
        self.registryCoder = registryCoder
        self.profile = profile
        self.strategy = strategy
    }

    public func send(to url: URL, passcode: String) async throws {
        pp_log_g(.app, .info, "WebUploader: sending to \(url) with passcode \(passcode)")
        let encodedProfile = try registryCoder.string(from: profile)

        var formBuilder = MultipartForm.Builder()
        formBuilder.fields["passcode"] = MultipartForm.Field(passcode)
        formBuilder.fields["file"] = MultipartForm.Field(encodedProfile, filename: profile.name)
        let form = formBuilder.build()
        try await strategy.upload(form, to: url)
    }
}
