//
//  PresetMapper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
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
import CoreData
import PassepartoutCore
import PassepartoutServices
import PassepartoutUtils
import GenericJSON

struct PresetMapper: DTOMapper, ModelMapper {
    private let context: NSManagedObjectContext

    init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func toDTO(_ ws: WSProviderPreset) -> CDInfrastructurePreset {
        let preset = CDInfrastructurePreset(context: context)
        preset.id = ws.id
        preset.name = ws.name
        preset.comment = ws.comment
        if let ovpn = ws.encodedOpenVPNConfiguration {
            preset.vpnProtocol = VPNProtocolType.openVPN.rawValue
            preset.vpnConfiguration = ovpn
        } else if let wg = ws.encodedWireGuardConfiguration {
            preset.vpnProtocol = VPNProtocolType.wireGuard.rawValue
            preset.vpnConfiguration = wg
        }
        return preset
    }

    static func toModel(_ dto: CDInfrastructurePreset) -> ProviderServer.Preset? {
        guard let id = dto.id,
              let name = dto.name,
              let comment = dto.comment,
              let vpnProtocolString = dto.vpnProtocol,
              let vpnProtocol = VPNProtocolType(rawValue: vpnProtocolString),
              let vpnConfiguration = dto.decodedConfiguration else {

            Utils.assertCoreDataDecodingFailed(#file, #function, #line)
            return nil
        }

        return ProviderServer.Preset(
            id: id,
            name: name,
            comment: comment,
            vpnProtocol: vpnProtocol,
            vpnConfiguration: vpnConfiguration
        )
    }
}

private extension WSProviderPreset {
    var encodedOpenVPNConfiguration: Data? {
        return try? jsonOpenVPNConfiguration?.encoded()
    }

    var encodedWireGuardConfiguration: Data? {
        return try? jsonWireGuardConfiguration?.encoded()
    }
}

private extension CDInfrastructurePreset {
    var decodedConfiguration: JSON? {
        guard let configuration = vpnConfiguration else {
            return nil
        }
        do {
            let raw = try JSONSerialization.jsonObject(with: configuration)
            return try JSON(raw)
        } catch {
            pp_log.error("Unable to decode vpnConfiguration: \(error)")
            return nil
        }
    }
}
