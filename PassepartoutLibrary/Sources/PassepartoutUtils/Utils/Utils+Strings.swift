//
//  Utils+Strings.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/26/22.
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
#if os(iOS)
import UIKit
#else
import AppKit
#endif

extension Utils {
    public static func copyToPasteboard(_ string: String) {
        #if os(iOS)
        let pb = UIPasteboard.general
        pb.string = string
        #else
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(string, forType: .string)
        #endif
    }
}

extension String: StrippableContent {
    public var stripped: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var strippedNotEmpty: String? {
        let string = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !string.isEmpty else {
            return nil
        }
        return string
    }
}

extension StringProtocol where Index == String.Index {
    public func nsRange(from range: Range<Index>) -> NSRange {
        NSRange(range, in: self)
    }
}

extension String {
    public var localizedAsCountryCode: String {
        Locale.current.localizedString(forRegionCode: self) ?? self
    }
}

extension CharacterSet {
    public static let filename: CharacterSet = {
        var chars: CharacterSet = .decimalDigits
        let english = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let symbols = " -_."
        chars.formUnion(CharacterSet(charactersIn: english))
        chars.formUnion(CharacterSet(charactersIn: english.lowercased()))
        chars.formUnion(CharacterSet(charactersIn: symbols))
        return chars
    }()
}

extension NSRegularExpression {
    public convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern, options: [])
        } catch {
            fatalError("Could not create NSRegularExpression: \(error)")
        }
    }
}
