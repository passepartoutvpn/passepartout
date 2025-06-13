//
//  HTTPAddressPort.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/13/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import Foundation

struct HTTPAddressPort {
    enum Scheme: String {
        case http

        case https
    }

    var scheme: Scheme = .http

    var address = ""

    var port = ""

    var url: URL? {
        guard let port = Int(port) else {
            return nil
        }
        guard !address.isEmpty else {
            return nil
        }
        return URL(string: "\(scheme)://\(address):\(port)")
    }

    var urlDescription: String? {
        let addressDescription = {
            !address.isEmpty ? address : "<\(Strings.Global.Nouns.address.lowercased())>"
        }
        guard let port = Int(port) else {
            let portDescription = "<\(Strings.Global.Nouns.port.lowercased())>"
            return "\(scheme)://\(addressDescription()):\(portDescription)"
        }
        guard !address.isEmpty else {
            return "\(scheme)://\(addressDescription()):\(port)"
        }
        return url?.absoluteString
    }
}

extension HTTPAddressPort {
    static var forWebReceiver: HTTPAddressPort {
        HTTPAddressPort(port: String(Constants.shared.webReceiver.port))
    }
}
