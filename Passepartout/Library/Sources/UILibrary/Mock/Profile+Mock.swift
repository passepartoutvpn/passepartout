//
//  Profile+Mock.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/4/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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
import PassepartoutKit

extension Profile {
    public static let mock: Profile = {
        var profile = Profile.Builder()
        profile.name = "Mock profile"

        do {
            var ovpn = OpenVPNModule.Builder()
            ovpn.configurationBuilder = OpenVPN.Configuration.Builder(withFallbacks: true)
            ovpn.configurationBuilder?.ca = .init(pem: "some CA")
            ovpn.configurationBuilder?.remotes = [
                try .init("1.2.3.4", .init(.udp, 80))
            ]
            profile.modules.append(try ovpn.tryBuild())

            var dns = DNSModule.Builder()
            dns.protocolType = .https
            dns.servers = ["1.1.1.1"]
            dns.dohURL = "https://1.1.1.1/dns-query"
            profile.modules.append(try dns.tryBuild())

            var proxy = HTTPProxyModule.Builder()
            proxy.address = "1.1.1.1"
            proxy.port = 1080
            proxy.secureAddress = "2.2.2.2"
            proxy.securePort = 8080
            proxy.bypassDomains = ["bypass.com"]
            profile.modules.append(try proxy.tryBuild())

            profile.activeModulesIds = [ovpn.id, dns.id]

            return try profile.tryBuild()
        } catch {
            fatalError("Unable to build: \(error)")
        }
    }()

    public static func newMockProfile() -> Profile {
        do {
            var copy = mock.builder(withNewId: true)
            copy.name = String(copy.id.uuidString.prefix(8))
            return try copy.tryBuild()
        } catch {
            fatalError("Unable to build: \(error)")
        }
    }
}
