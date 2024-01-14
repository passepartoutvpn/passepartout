//
//  Validators.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/31/22.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

public struct Validators {
    public enum ValidationError: Error {
        case notSet

        case empty

        case ipAddress

        case socketPort

        case domainName

        case wildcardDomainName

        case url
    }

    private static let rxDomainName = NSRegularExpression("^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,}$")

    private static let rxWildcardDomainName = NSRegularExpression("^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.|\\*\\.)+([A-Za-z]{2,}|\\*)$")

    public static func notNil(_ string: String?) throws {
        guard string != nil else {
            throw ValidationError.notSet
        }
    }

    public static func notEmpty(_ string: String) throws {
        let valid = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !valid.isEmpty else {
            throw ValidationError.empty
        }
    }

    public static func ipAddress(_ string: String) throws {
        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()

        guard string.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 ||
                string.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 else {

            throw ValidationError.ipAddress
        }
    }

    public static func socketPort(_ string: String) throws {
        guard let num = Int(string),
              (Int(UInt16.min)...Int(UInt16.max)).contains(num) else {
            throw ValidationError.socketPort
        }
    }

    public static func domainName(_ string: String) throws {
        guard rxDomainName.numberOfMatches(in: string, options: [], range: .init(location: 0, length: string.count)) > 0 else {
            throw ValidationError.domainName
        }
    }

    public static func wildcardDomainName(_ string: String) throws {
        guard rxWildcardDomainName.numberOfMatches(in: string, options: [], range: .init(location: 0, length: string.count)) > 0 else {
            throw ValidationError.wildcardDomainName
        }
    }

    public static func url(_ string: String) throws {
        guard URL(string: string) != nil else {
            throw ValidationError.url
        }
    }

    public static func dnsOverTLSServerName(_ string: String) throws {
        do {
            try domainName(string)
        } catch {
            try ipAddress(string)
        }
    }
}
