//
//  PushReply.swift
//  Partout
//
//  Created by Davide De Rosa on 7/25/18.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//
//  This file incorporates work covered by the following copyright and
//  permission notice:
//
//      Copyright (c) 2018-Present Private Internet Access
//
//      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import Partout

struct PushReply {
    private let original: String

    let options: OpenVPN.Configuration

    fileprivate init(original: String, options: OpenVPN.Configuration) {
        self.original = original
        self.options = options
    }
}

extension PushReply: CustomStringConvertible {
    var description: String {
        let stripped = NSMutableString(string: original)
        let rx = NSRegularExpression(StandardOpenVPNParser.Option.authToken.rawValue)
        rx.replaceMatches(
            in: stripped,
            options: [],
            range: NSRange(location: 0, length: stripped.length),
            withTemplate: "auth-token"
        )
        return stripped as String
    }
}

extension StandardOpenVPNParser {
    private static let prefix = "PUSH_REPLY,"

    func pushReply(with message: String) throws -> PushReply? {
        guard message.hasPrefix(Self.prefix) else {
            return nil
        }
        guard let prefixIndex = message.range(of: Self.prefix)?.lowerBound else {
            return nil
        }
        guard !message.contains("push-continuation 2") else {
            throw StandardOpenVPNParserError.continuationPushReply
        }
        let original = String(message[prefixIndex...])
        let lines = original.components(separatedBy: ",")
        let options = try parsed(fromLines: lines).configuration

        return PushReply(original: original, options: options)
    }
}
