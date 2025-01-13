//
//  OCCPacket.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 5/2/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import PassepartoutKit

enum OCCPacket: UInt8 {
    case exit = 0x06

    private static let magicString = Data(hex: "287f346bd4ef7a812d56b8d3afc5459c")

    func serialized(_ info: Any? = nil) -> Data {
        var data = OCCPacket.magicString
        data.append(rawValue)
        switch self {
        case .exit:
            break // nothing more
        }
        return data
    }
}
