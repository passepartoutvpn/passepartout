//
//  ChangelogEntry+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/2/25.
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

extension ChangelogEntry {
    public var issueURL: URL? {
        issue.map {
            Constants.shared.websites.issues.appendingPathComponent($0.description)
        }
    }
}

extension ChangelogEntry {
    private static let entryPrefix = "* "

    public init?(_ index: Int, line: String) {
        guard line.hasPrefix(Self.entryPrefix) else {
            return nil
        }
        var comps = line.split(separator: " ")
        comps.removeFirst()

        let optionalIssue: Int?
        if comps.count >= 2, let last = comps.last,
           last.hasPrefix("(#"), last.hasSuffix(")") {
            let lastString = String(last)
            let start = lastString.index(lastString.startIndex, offsetBy: 2)
            let end = lastString.index(lastString.endIndex, offsetBy: -1)
            let issueString = lastString[start..<end]
            if let issue = Int(issueString) {
                comps.removeLast()
                optionalIssue = issue
            } else {
                optionalIssue = nil
            }
        } else {
            optionalIssue = nil
        }

        self.init(index, comps.joined(separator: " "), optionalIssue)
    }
}
