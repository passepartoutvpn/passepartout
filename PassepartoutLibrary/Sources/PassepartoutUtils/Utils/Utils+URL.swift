//
//  Utils+URL.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/16/18.
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
import StoreKit
#if os(iOS)
import UIKit
#else
import AppKit
#endif

extension URL {
    public var filename: String {
        deletingPathExtension().lastPathComponent
    }

    @discardableResult
    public static func openURL(_ url: URL) -> Bool {
        #if os(iOS)
        guard UIApplication.shared.canOpenURL(url) else {
            return false
        }
        UIApplication.shared.open(url)
        return true
        #else
        NSWorkspace.shared.open(url)
        #endif
    }

    public static func mailto(to: String, subject: String, body: String) -> URL? {
       guard let escapedSubject = subject.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
           return nil
       }
       guard let escapedBody = body.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
           return nil
       }
       return URL(string: "mailto:\(to)?subject=\(escapedSubject)&body=\(escapedBody)")
    }

    public func trailingContent(bytes: UInt64) -> String {
        var file: FileHandle?
        defer {
            try? file?.close()
        }
        do {
            file = try FileHandle(forReadingFrom: self)
            guard let size = try file?.seekToEnd() else {
                pp_log.error("Cannot seek")
                return ""
            }

            var offset: UInt64
            if bytes < size {
                offset = size - bytes
            } else {
                offset = 0
            }

            try file?.seek(toOffset: offset)
            guard let data = try file?.readToEnd() else {
                pp_log.error("No data")
                return ""
            }
            guard let string = String(data: data, encoding: .utf8) else {
                pp_log.error("Cannot encode string")
                return ""
            }
            return string
        } catch {
            pp_log.error("Error while reading file: \(error)")
            return ""
        }
    }

    public func trailingLines(bytes: UInt64) -> [String] {
        let content = trailingContent(bytes: bytes)
        return content
            .components(separatedBy: "\n")
            .filter {
                !$0.isEmpty
            }
    }
}
