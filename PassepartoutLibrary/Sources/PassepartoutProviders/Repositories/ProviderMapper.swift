//
//  ProviderMapper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/15/22.
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

struct ProviderMapper: DTOMapper, ModelMapper {
    private let context: NSManagedObjectContext

    init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func toDTO(_ ws: WSProvidersIndex.Metadata) -> CDProvider {
        let provider = CDProvider(context: context)
        provider.name = ws.name
        provider.fullName = ws.fullName
        provider.lastUpdate = Date()

        ws.supportedVPNProtocols.forEach {
            let infra = CDInfrastructure(context: context)
            infra.vpnProtocol = $0.rawValue
            infra.lastUpdate = nil
            infra.provider = provider
            provider.addToInfrastructures(infra)
        }

        return provider
    }

    static func toModel(_ dto: CDProvider) -> ProviderMetadata? {
        guard let name = dto.name,
              let fullName = dto.fullName else {

            Utils.assertCoreDataDecodingFailed(#file, #function, #line)
            return nil
        }

        var protos: [VPNProtocolType] = []
        if let infraDTOs = dto.infrastructures?.allObjects as? [CDInfrastructure] {
            protos = infraDTOs
                .compactMap(\.vpnProtocol)
                .compactMap(VPNProtocolType.init(rawValue:))
        }

        return ProviderMetadata(name: name, fullName: fullName, supportedVPNProtocols: protos)
    }
}
