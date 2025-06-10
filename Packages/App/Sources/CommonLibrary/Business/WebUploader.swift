//
//  WebUploader.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/9/25.
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
