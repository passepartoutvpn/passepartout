//
//  OpenVPNSessionError.swift
//  Partout
//
//  Created by Davide De Rosa on 8/23/18.
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

internal import CPartoutOpenVPNOpenSSL
import Foundation

/// Thrown during ``OpenVPNSession`` operation.
enum OpenVPNSessionError: Error {

    /// Recoverable error (reconnecting may resolve).
    case recoverable(_ error: Error?)

    /// The negotiation timed out.
    case negotiationTimeout

    /// The VPN session id is missing.
    case missingSessionId

    /// The VPN session id doesn't match.
    case sessionMismatch

    /// The connection key is wrong or wasn't expected.
    case badKey

    /// Control channel failure.
    case controlChannel(message: String)

    /// The control packet has an incorrect prefix payload.
    case wrongControlDataPrefix

    /// The provided credentials failed authentication.
    case badCredentials

    /// The provided credentials failed authentication, but should retry without local options.
    case badCredentialsWithLocalOptions

    /// The reply to PUSH_REQUEST is malformed.
    case malformedPushReply

    /// A write operation took too long.
    case writeTimeout

    /// The server couldn't ping back before timeout.
    case pingTimeout

    /// The session reached a stale state and can't be recovered.
    case staleSession

    /// Server uses compression.
    case serverCompression

    /// Missing routing information.
    case noRouting

    /// Remote server shut down (--explicit-exit-notify).
    case serverShutdown

    /// Programming errors.
    case assertion

    /// NSError from the Objective-C layer, see `CPartoutOpenVPN`.
    case native(code: OpenVPNErrorCode)
}

extension Error {
    var asNativeOpenVPNError: OpenVPNSessionError? {
        let nativeError = self as NSError
        guard nativeError.domain == OpenVPNErrorDomain, let code = OpenVPNErrorCode(rawValue: nativeError.code) else {
            return nil
        }
        return .native(code: code)
    }
}
