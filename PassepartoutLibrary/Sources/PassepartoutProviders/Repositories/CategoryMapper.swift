//
//  CategoryMapper.swift
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
import PassepartoutCore
import PassepartoutServices
import PassepartoutUtils
import CoreData

struct CategoryMapper: DTOMapper, ModelMapper {
    private let context: NSManagedObjectContext

    private let vpnProtocol: VPNProtocolType

    init(_ context: NSManagedObjectContext, _ vpnProtocol: VPNProtocolType) {
        self.context = context
        self.vpnProtocol = vpnProtocol
    }

    func toDTO(_ ws: WSProviderCategory) -> CDInfrastructureCategory {
        let category = CDInfrastructureCategory(context: context)
        let locations = ws.locations.compactMap(LocationMapper(context).toDTO)

        category.name = ws.name
        locations.forEach {
            $0.category = category
            $0.servers?.forEach {
                ($0 as? CDInfrastructureServer)?.category = category
            }
        }
        category.addToLocations(Set(locations) as NSSet)

        return category
    }

    static func toModel(_ dto: CDInfrastructureCategory) -> ProviderCategory? {
        guard let infrastructureDTO = dto.infrastructure,
              let providerDTO = infrastructureDTO.provider,
              let providerMetadata = ProviderMapper.toModel(providerDTO),
              let vpnProtocolString = infrastructureDTO.vpnProtocol,
              let vpnProtocol = VPNProtocolType(rawValue: vpnProtocolString),
              let name = dto.name,
              let locations = dto.locations else {

            Utils.assertCoreDataDecodingFailed(#file, #function, #line)
            return nil
        }

        let locationModels = (locations.allObjects as? [CDInfrastructureLocation])?
            .compactMap(LocationMapper.toModel) ?? []

        return ProviderCategory(
            providerMetadata: providerMetadata,
            vpnProtocol: vpnProtocol,
            name: name,
            locations: locationModels
        )
    }
}
