//
//  Empty.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/10/25.
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

public final class URLSessionUploaderStrategy: WebUploaderStrategy {
    public init() {
    }

    public func upload(_ form: MultipartForm, to url: URL) async throws {
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
