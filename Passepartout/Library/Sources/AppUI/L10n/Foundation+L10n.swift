//
//  Foundation+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/18/24.
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
import CommonUtils

extension TimeInterval: StyledLocalizableEntity {
    public enum Style {
        case timeString
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .timeString:
            if self > 0 {
                return asTimeString
            } else {
                return Strings.Global.disabled
            }
        }
    }
}

extension Date: StyledLocalizableEntity {
    public enum Style {
        case timestamp
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .timestamp:
            return Self.timestampFormatter.string(from: self)
        }
    }

    private static let timestampFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        return fmt
    }()
}

extension UUID {
    public var flatString: String {
        let str = uuidString.replacingOccurrences(of: "-", with: "")
        assert(str.count == 32)
        return str
    }
}

extension String: StyledLocalizableEntity {
    public enum Style {
        case quartets
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .quartets:
            return matrix(of: 4, each: 4)
        }
    }

    private func matrix(of word: Int, each: Int, _ columnSeparator: String = " ", _ rowSeparator: String = "\n") -> String {
        var groups: [[String]] = []
        var currentGroup: [String] = []
        var currentString: [Character] = []
        var i = 0
        var j = 0
        for ch in self {
            currentString.append(ch)
            i = (i + 1) % word
            if i == 0 {
                currentGroup.append(String(currentString))
                currentString = []

                j = (j + 1) % each
                if j == 0 {
                    groups.append(currentGroup)
                    currentGroup = []
                }
            }
        }
        return groups
            .map {
                $0.joined(separator: columnSeparator)
            }
            .joined(separator: rowSeparator)
    }
}
