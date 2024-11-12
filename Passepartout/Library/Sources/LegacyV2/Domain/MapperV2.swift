//
//  MapperV2.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/12/24.
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

struct MapperV2 {

    // FIXME: #642, migrate profiles properly
    func toProfileV3(_ v2: ProfileV2) throws -> Profile {
        var builder = Profile.Builder(id: v2.id)
        var modules: [Module] = []

        builder.name = v2.header.name
        builder.attributes.lastUpdate = v2.header.lastUpdate

        modules.append(toOnDemandModule(v2.onDemand))

        if let provider = v2.provider {
//            v2.provider
        } else if let ovpn = v2.host?.ovpnSettings {
            modules.append(try toOpenVPNModule(ovpn))
        } else if let wg = v2.host?.wgSettings {
            modules.append(try toWireGuardModule(wg))
        }

//        v2.networkSettings
//        toNetworkModules(v2.networkSettings)

        builder.modules = modules
        builder.activeModulesIds = Set(modules.map(\.id))
        return try builder.tryBuild()
    }
}

private extension MapperV2 {
    func toOnDemandModule(_ v2: ProfileV2.OnDemand) -> OnDemandModule {
        var builder = OnDemandModule.Builder()
        builder.isEnabled = v2.isEnabled
        switch v2.policy {
        case .any:
            builder.policy = .any
        case .excluding:
            builder.policy = .excluding
        case .including:
            builder.policy = .including
        }
        builder.withSSIDs = v2.withSSIDs
        builder.withOtherNetworks = Set(v2.withOtherNetworks.map {
            switch $0 {
            case .ethernet:
                return .ethernet
            case .mobile:
                return .mobile
            }
        })
        return builder.tryBuild()
    }

    func toOpenVPNModule(_ v2: ProfileV2.OpenVPNSettings) throws -> OpenVPNModule {
        var builder = OpenVPNModule.Builder()
        builder.configurationBuilder = v2.configuration.builder()
        builder.credentials = v2.account.map {
            OpenVPN.Credentials.Builder(username: $0.username, password: $0.password)
                .build()
        }
        return try builder.tryBuild()
    }

    func toWireGuardModule(_ v2: ProfileV2.WireGuardSettings) throws -> WireGuardModule {
        var builder = WireGuardModule.Builder()
        builder.configurationBuilder = v2.configuration.configuration.builder()
        return try builder.tryBuild()
    }
}
