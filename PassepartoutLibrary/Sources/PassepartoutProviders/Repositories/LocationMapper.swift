//
//  LocationMapper.swift
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

struct LocationMapper: DTOMapper, ModelMapper {
    private let context: NSManagedObjectContext

    init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func toDTO(_ ws: WSProviderLocation) -> CDInfrastructureLocation {
        let location = CDInfrastructureLocation(context: context)
        location.countryCode = ws.countryCode

        let servers = ws.servers.compactMap(ServerMapper(context).toDTO)
        servers.forEach {
            $0.location = location
        }
        location.addToServers(Set(servers) as NSSet)

        return location
    }

    static func toModel(_ dto: CDInfrastructureLocation) -> ProviderLocation? {
        guard let infrastructureDTO = dto.category?.infrastructure,
              let providerDTO = infrastructureDTO.provider,
              let providerMetadata = ProviderMapper.toModel(providerDTO),
              let vpnProtocolString = infrastructureDTO.vpnProtocol,
              let vpnProtocol = VPNProtocolType(rawValue: vpnProtocolString),
              let categoryName = dto.category?.name,
              let countryCode = dto.countryCode else {

            Utils.assertCoreDataDecodingFailed(#file, #function, #line)
            return nil
        }

//        var server: ProviderServer?
//        if dto.servers?.count == 1, let serverDTO = dto.servers?.anyObject() as? CDInfrastructureServer {
//            server = ServerMapper.toModel(serverDTO)
//        }
        let servers = (dto.servers?.allObjects as? [CDInfrastructureServer])?
            .compactMap(ServerMapper.toModel)

        return ProviderLocation(
            providerMetadata: providerMetadata,
            vpnProtocol: vpnProtocol,
            categoryName: categoryName,
            countryCode: countryCode,
//            servers: server.map {
//                [$0]
//            }
            servers: servers
        )
    }
}
