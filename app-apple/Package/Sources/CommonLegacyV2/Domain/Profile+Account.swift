// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

extension ProfileV2 {
    struct Account: Codable, Equatable {
        enum AuthenticationMethod: String, Codable {
            case persistent

            case interactive

            case totp
        }

        var authenticationMethod: AuthenticationMethod?

        var username: String

        var password: String

        var isEmpty: Bool {
            username.isEmpty && password.isEmpty
        }

        init() {
            username = ""
            password = ""
        }

        init(_ username: String, _ password: String) {
            self.username = username
            self.password = password
        }
    }
}
