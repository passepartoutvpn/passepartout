//
//  String+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/8/24.
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

import Foundation

extension String {
    public var nilIfEmpty: String? {
        !isEmpty ? self : nil
    }

    public var forMenu: String {
#if os(macOS)
        withTrailingDots
#else
        self
#endif
    }

    public var withTrailingDots: String {
        "\(self)..."
    }

    public func trimmedSplit(separator: String) -> [String] {
        split(separator: separator)
            .map {
                $0.trimmingCharacters(in: .whitespaces)
            }
    }
}

extension String {
    private static let alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    public static func random(count: Int) -> String {
        precondition(count > 0)
        var chars = [Character](repeating: " ", count: count)
        for charIndex in 0..<count {
            let alphabetIndex = alphabet.index(
                alphabet.startIndex,
                offsetBy: .random(in: 0..<alphabet.count)
            )
            let ch = alphabet[alphabetIndex]
            chars[charIndex] = ch
        }
        return String(chars)
    }
}

extension String {
    public var localizedAsRegionCode: String? {
        Locale
            .current
            .localizedString(forRegionCode: self)?
            .capitalized
    }

    public var localizedAsLanguageCode: String? {
        Locale
            .current
            .localizedString(forLanguageCode: self)?
            .capitalized
    }
}

extension String {
    private static let iso8601: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = .withFullDate
        return fmt
    }()

    public var asISO8601Date: Date? {
        Self.iso8601.date(from: self)
    }
}

extension String {
    public var asCountryCodeEmoji: String {
        Self.emoji(forCountryCode: self)
    }

    public static func emoji(forCountryCode countryCode: String) -> String {
        let points = countryCode
            .unicodeScalars
            .compactMap {
                UnicodeScalar(127397 + $0.value)
            }

        return String(String.UnicodeScalarView(points))
    }
}
