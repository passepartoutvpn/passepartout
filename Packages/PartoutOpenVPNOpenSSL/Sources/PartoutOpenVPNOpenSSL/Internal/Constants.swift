//
//  Constants.swift
//  Partout
//
//  Created by Davide De Rosa on 5/19/19.
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
import Partout

struct Constants {

    // MARK: Session

    static let usesReplayProtection = true

    static let maxPacketSize = 1000

    // MARK: Authentication

    static func peerInfo(sslVersion: String? = nil, withPlatform: Bool = true, extra: [String: String]? = nil) -> String {
        let uiVersion = PartoutConfiguration.shared.versionIdentifier
        var info = [
            "IV_VER=2.4",
            "IV_UI_VER=\(uiVersion)",
            "IV_PROTO=2",
            "IV_NCP=2",
            "IV_LZO_STUB=1"
        ]
        if LZOFactory.canCreate() {
            info.append("IV_LZO=1")
        }
        // XXX: always do --push-peer-info
        // however, MAC is inaccessible and IFAD is deprecated, skip IV_HWADDR
//            if pushPeerInfo {
        if let sslVersion {
            info.append("IV_SSL=\(sslVersion)")
        }
        if withPlatform {
            let platform: String
            let platformVersion = ProcessInfo.processInfo.operatingSystemVersion
#if os(iOS)
            platform = "ios"
#elseif os(tvOS)
            platform = "tvos"
#else
            platform = "mac"
#endif
            info.append("IV_PLAT=\(platform)")
            info.append("IV_PLAT_VER=\(platformVersion.majorVersion).\(platformVersion.minorVersion)")
        }
        if let extra {
            info.append(contentsOf: extra.map {
                "\($0)=\($1)"
            })
        }
        info.append("")
        return info.joined(separator: "\n")
    }

    static let randomLength = 32

    // MARK: Keys

    static let label1 = "OpenVPN master secret"

    static let label2 = "OpenVPN key expansion"

    static let preMasterLength = 48

    static let keyLength = 64

    static let keysCount = 4
}
