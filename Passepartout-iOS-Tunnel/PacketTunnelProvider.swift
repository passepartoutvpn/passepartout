//
//  PacketTunnelProvider.swift
//  Passepartout-iOS-Tunnel
//
//  Created by Davide De Rosa on 6/6/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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

import TunnelKit

class PacketTunnelProvider: TunnelKitProvider {
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        appVersion = "\(GroupConstants.App.name) \(GroupConstants.App.versionString)"
        dnsTimeout = GroupConstants.VPN.dnsTimeout
        logSeparator = GroupConstants.VPN.sessionMarker
        super.startTunnel(options: options, completionHandler: completionHandler)
    }
}
