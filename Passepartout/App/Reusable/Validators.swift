//
//  Validators.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/31/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import Foundation

struct Validators {
    enum ValidationError: Error {
        case notSet

        case empty

        case ipAddress

        case domainName

        case url
    }

    static func notNil(_ string: String?) throws {
        guard string != nil else {
            throw ValidationError.notSet
        }
    }

    static func notEmpty(_ string: String) throws {
        let valid = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !valid.isEmpty else {
            throw ValidationError.empty
        }
    }

    static func ipAddress(_ string: String) throws {
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()

        if string.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            return
        }
        if string.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            return
        }
        throw ValidationError.ipAddress
    }

    private static let rxDomainName = NSRegularExpression("^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,6}$")

    static func domainName(_ string: String) throws {
        guard rxDomainName.numberOfMatches(in: string, options: [], range: .init(location: 0, length: string.count)) > 0 else {
            throw ValidationError.domainName
        }
    }

    static func url(_ string: String) throws {
        guard URL(string: string) != nil else {
            throw ValidationError.url
        }
    }

    static func dnsOverTLSServerName(_ string: String) throws {
        do {
            try domainName(string)
        } catch {
            try ipAddress(string)
        }
    }
}
