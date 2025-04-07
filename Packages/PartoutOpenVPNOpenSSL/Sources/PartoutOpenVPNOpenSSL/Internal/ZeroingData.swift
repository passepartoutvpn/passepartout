//
//  ZeroingData.swift
//  Partout
//
//  Created by Davide De Rosa on 1/8/25.
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

internal import CPartoutCryptoOpenSSL
import Foundation

func Z() -> ZeroingData {
    ZeroingData()
}

func Z(length: Int) -> ZeroingData {
    ZeroingData(length: length)
}

func Z(bytes: UnsafePointer<UInt8>, length: Int) -> ZeroingData {
    ZeroingData(bytes: bytes, length: length)
}

func Z(_ uint8: UInt8) -> ZeroingData {
    ZeroingData(uInt8: uint8)
}

func Z(_ uint16: UInt16) -> ZeroingData {
    ZeroingData(uInt16: uint16)
}

func Z(_ data: Data) -> ZeroingData {
    ZeroingData(data: data)
}

func Z(_ data: Data, _ offset: Int, _ length: Int) -> ZeroingData {
    ZeroingData(data: data, offset: offset, length: length)
}

func Z(_ string: String, nullTerminated: Bool) -> ZeroingData {
    ZeroingData(string: string, nullTerminated: nullTerminated)
}
