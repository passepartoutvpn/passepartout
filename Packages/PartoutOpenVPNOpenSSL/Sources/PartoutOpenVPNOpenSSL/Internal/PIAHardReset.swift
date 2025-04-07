//
//  PIAHardReset.swift
//  Partout
//
//  Created by Davide De Rosa on 10/18/18.
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

struct PIAHardReset {
    private static let obfuscationKeyLength = 3

    private static let magic = "53eo0rk92gxic98p1asgl5auh59r1vp4lmry1e3chzi100qntd"

    private static let encodedFormat = "\(magic)crypto\t%@|%@\tca\t%@"

    private let caMd5Digest: String

    private let cipherName: String

    private let digestName: String

    init(caMd5Digest: String, cipher: OpenVPN.Cipher, digest: OpenVPN.Digest) {
        self.caMd5Digest = caMd5Digest
        cipherName = cipher.rawValue.lowercased()
        digestName = digest.rawValue.lowercased()
    }

    func encodedData(prng: PRNGProtocol) throws -> Data {
        let string = String(format: PIAHardReset.encodedFormat, cipherName, digestName, caMd5Digest)
        guard let plainData = string.data(using: .ascii) else {
            pp_log(.openvpn, .fault, "Unable to encode string to ASCII")
            throw OpenVPNSessionError.assertion
        }
        let keyBytes = prng.data(length: PIAHardReset.obfuscationKeyLength)

        var encodedData = Data(keyBytes)
        for (i, b) in plainData.enumerated() {
            let keyChar = keyBytes[i % keyBytes.count]
            let xorredB = b ^ keyChar

            encodedData.append(xorredB)
        }
        return encodedData
    }
}
