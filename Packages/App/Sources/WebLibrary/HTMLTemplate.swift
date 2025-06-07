//
//  HTMLTemplate.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/6/25.
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

struct HTMLTemplate {
    private static let keyPattern: NSRegularExpression = {
        do {
            let pattern = #"#\{([^}]+)\}"#
            return try NSRegularExpression(pattern: pattern)
        } catch {
            fatalError("Unable to create web uploader template regular expression")
        }
    }()

    private let html: String

    init(html: String) {
        self.html = html
    }

    func withLocalizedKeys(in bundle: Bundle) -> String {
        let range = NSRange(html.startIndex..., in: html)
        var result = ""
        var lastRangeEnd = html.startIndex

        Self.keyPattern.enumerateMatches(in: html, range: range) { match, _, _ in
            guard let match = match,
                  let fullRange = Range(match.range(at: 0), in: html),
                  let keyRange = Range(match.range(at: 1), in: html) else {
                return
            }

            result += html[lastRangeEnd..<fullRange.lowerBound]
            let key = String(html[keyRange])
            let localized = bundle.localizedString(forKey: key, value: key, table: "Localizable")

            result += localized
            lastRangeEnd = fullRange.upperBound
        }

        result += html[lastRangeEnd...]

        return result
    }
}
