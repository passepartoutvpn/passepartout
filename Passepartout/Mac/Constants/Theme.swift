//
//  Theme.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/9/22.
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
import AppKit

private let bundle = Constants.Mac.bundle

extension LightVPNStatus {
    var localizedDescription: String {
        switch self {
        case .connecting:
            return L10n.Tunnelkit.Vpn.connecting

        case .connected:
            return L10n.Tunnelkit.Vpn.active

        case .disconnecting:
            return L10n.Tunnelkit.Vpn.disconnecting

        case .disconnected:
            return L10n.Tunnelkit.Vpn.inactive
        }
    }
}

extension LightVPNStatus {
    var image: NSImage {
        let resourceName: String
        switch self {
        case .connected, .disconnected:
            resourceName = "StatusActive"

        case .connecting, .disconnecting:
            resourceName = "StatusPending"
        }
        guard let image = bundle.image(forResource: resourceName) else {
            fatalError("Resource not found: \(resourceName)")
        }
        return image
    }

    var imageAlpha: Double {
        switch self {
        case .disconnected:
            return 0.5

        default:
            return 1.0
        }
    }
}

extension LightProviderLocation {
    var nsImage: NSImage? {
        bundle.image(forResource: "flags/\(countryCode.lowercased())")
    }
}
