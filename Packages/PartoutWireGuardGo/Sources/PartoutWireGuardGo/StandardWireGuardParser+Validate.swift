//
//  StandardWireGuardParser+Validate.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/25/25.
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

import Foundation
import Partout
internal import WireGuardKit

extension StandardWireGuardParser: ModuleBuilderValidator {
    public func validate(_ builder: any ModuleBuilder) throws {
        guard let builder = builder as? WireGuardModule.Builder else {
            throw PartoutError(.unknownModuleHandler)
        }
        guard let configurationBuilder = builder.configurationBuilder else {
            // assume provider configurations to be valid
            return
        }
        do {
            let quickConfig = configurationBuilder.toQuickConfig()
            _ = try TunnelConfiguration(fromWgQuickConfig: quickConfig)
        } catch {
            throw PartoutError(.parsing, error)
        }
    }
}

private extension WireGuard.Configuration.Builder {
    func toQuickConfig() -> String {
        var lines: [String] = []

        lines.append("[Interface]")
        lines.append("PrivateKey = \(interface.privateKey)")
        if !interface.addresses.isEmpty {
            lines.append("Address = \(interface.addresses.wgJoined)")
        }
        let dnsEntries = interface.dns.servers + (interface.dns.searchDomains ?? [])
        if !dnsEntries.isEmpty {
            lines.append("DNS = \(dnsEntries.wgJoined)")
        }
        if let mtu = interface.mtu {
            lines.append("MTU = \(mtu)")
        }

        peers.forEach {
            lines.append("[Peer]")
            lines.append("PublicKey = \($0.publicKey)")
            if let preSharedKey = $0.preSharedKey, !preSharedKey.isEmpty {
                lines.append("PresharedKey = \(preSharedKey)")
            }
            if !$0.allowedIPs.isEmpty {
                lines.append("AllowedIPs = \($0.allowedIPs.wgJoined)")
            }
            if let endpoint = $0.endpoint {
                lines.append("Endpoint = \(endpoint)")
            }
            if let persistentKeepAlive = $0.keepAlive {
                lines.append("PersistentKeepalive = \(persistentKeepAlive)")
            }
        }

        return lines.joined(separator: "\n")
    }
}

private extension Collection where Element == String {
    var wgJoined: String {
        joined(separator: ",")
    }
}
