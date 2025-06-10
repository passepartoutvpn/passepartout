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

    public init(registryCoder: RegistryCoder, profile: Profile) {
        self.registryCoder = registryCoder
        self.profile = profile
    }

    public func send(to url: URL, passcode: String) async throws {
        pp_log_g(.app, .info, "WebUploader: sending to \(url) with passcode \(passcode)")
        let encodedProfile = try registryCoder.string(from: profile)

        var formBuilder = MultipartForm.Builder()
        formBuilder.fields["passcode"] = MultipartForm.Field(passcode)
        formBuilder.fields["file"] = MultipartForm.Field(encodedProfile, filename: profile.name)
        let form = formBuilder.build()
        let request = form.toURLRequest(url: url)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.webUploader(nil, nil)
            }
            let statusCode = httpResponse.statusCode
            guard statusCode == 200 else {
                switch statusCode {
                case 400:
                    assertionFailure("WebUploader: invalid form, bug in MultipartForm")
                case 403:
                    assertionFailure("WebUploader: passcode is missing or incorrect")
                case 404:
                    assertionFailure("WebUploader: URL not found")
                default:
                    break
                }
                throw AppError.webUploader(statusCode, nil)
            }
        } catch {
            throw AppError.webUploader(nil, error)
        }
    }
}
