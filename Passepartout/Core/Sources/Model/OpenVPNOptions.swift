//
//  OpenVPNOptions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/22/19.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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
import TunnelKit

extension OpenVPN.Cipher {
    public static let available: [OpenVPN.Cipher] = [
        .aes128cbc,
        .aes192cbc,
        .aes256cbc,
        .aes128gcm,
        .aes192gcm,
        .aes256gcm
    ]
}

extension OpenVPN.Digest {
    public static let available: [OpenVPN.Digest] = [
        .sha1,
        .sha224,
        .sha256,
        .sha384,
        .sha512
    ]
}

extension OpenVPN.CompressionFraming {
    public static let available: [OpenVPN.CompressionFraming] = [
        .disabled,
        .compLZO,
        .compress
    ]
}

extension OpenVPN.CompressionAlgorithm {
    public static let available: [OpenVPN.CompressionAlgorithm] = [
        .disabled,
        .LZO
    ]
}
