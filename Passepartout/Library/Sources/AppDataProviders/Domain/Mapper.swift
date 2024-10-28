//
//  Mapper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
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

import CoreData
import Foundation
import PassepartoutKit

struct CoreDataMapper {
    let context: NSManagedObjectContext

    @discardableResult
    func cdProvider(from metadata: ProviderMetadata, lastUpdate: Date?) -> CDProviderV3 {
        let entity = CDProviderV3(context: context)
        entity.providerId = metadata.id.rawValue
        entity.fullName = metadata.description
        entity.supportedConfigurationIds = metadata.supportedConfigurationIdentifiers.joined(separator: ",")
        entity.lastUpdate = lastUpdate
        return entity
    }

    @discardableResult
    func cdServer(from server: VPNServer) throws -> CDVPNServerV3 {
        let entity = CDVPNServerV3(context: context)
        let encoder = JSONEncoder()
        entity.serverId = server.serverId
        entity.hostname = server.hostname
        entity.ipAddresses = try server.ipAddresses.map {
            try encoder.encode($0)
        }
        entity.providerId = server.provider.id.rawValue
        entity.countryCode = server.provider.countryCode
        entity.categoryName = server.provider.categoryName
        entity.localizedCountry = server.provider.countryCode.localizedAsRegionCode
        entity.otherCountryCodes = server.provider.otherCountryCodes?.joined(separator: ",")
        entity.area = server.provider.area
        entity.supportedConfigurationIds = server.provider.supportedConfigurationIdentifiers?.joined(separator: ",")
        entity.supportedPresetIds = server.provider.supportedPresetIds?.joined(separator: ",")
        return entity
    }

    @discardableResult
    func cdPreset(from preset: AnyVPNPreset) throws -> CDVPNPresetV3 {
        let entity = CDVPNPresetV3(context: self.context)
        let encoder = JSONEncoder()
        entity.presetId = preset.presetId
        entity.providerId = preset.providerId.rawValue
        entity.presetDescription = preset.description
        entity.endpoints = try encoder.encode(preset.endpoints)
        entity.configurationId = preset.configurationIdentifier
        entity.configuration = preset.configuration
        return entity
    }
}

struct DomainMapper {
    func provider(from entity: CDProviderV3) -> ProviderMetadata? {
        guard let id = entity.providerId,
              let fullName = entity.fullName,
              let supportedConfigurationIds = entity.supportedConfigurationIds else {
            return nil
        }
        return ProviderMetadata(
            id,
            description: fullName,
            supportedConfigurationIdentifiers: Set(supportedConfigurationIds.components(separatedBy: ","))
        )
    }

    func lastUpdated(from entities: [CDProviderV3]) -> [ProviderID: Date] {
        entities.reduce(into: [:]) {
            guard let id = $1.providerId,
                  let lastUpdate = $1.lastUpdate else {
                return
            }
            $0[.init(rawValue: id)] = lastUpdate
        }
    }

    func preset(from entity: CDVPNPresetV3) throws -> AnyVPNPreset? {
        guard let presetId = entity.presetId,
              let presetDescription = entity.presetDescription,
              let providerId = entity.providerId,
              let configurationId = entity.configurationId,
              let configuration = entity.configuration else {
            return nil
        }

        let decoder = JSONDecoder()
        let endpoints = try entity.endpoints.map {
            try decoder.decode([EndpointProtocol].self, from: $0)
        } ?? []

        return AnyVPNPreset(
            providerId: .init(rawValue: providerId),
            presetId: presetId,
            description: presetDescription,
            endpoints: endpoints,
            configurationIdentifier: configurationId,
            configuration: configuration
        )
    }

    func server(from entity: CDVPNServerV3) throws -> VPNServer? {
        guard let serverId = entity.serverId,
              let providerId = entity.providerId,
              let categoryName = entity.categoryName,
              let countryCode = entity.countryCode else {
            return nil
        }

        let decoder = JSONDecoder()
        let hostname = entity.hostname
        let ipAddresses = try entity.ipAddresses.map {
            Set(try decoder.decode([Data].self, from: $0))
        }
        let supportedConfigurationIds = entity.supportedConfigurationIds?.components(separatedBy: ",")
        let supportedPresetIds = entity.supportedPresetIds?.components(separatedBy: ",")
        let otherCountryCodes = entity.otherCountryCodes?.components(separatedBy: ",")
        let area = entity.area

        let provider = VPNServer.Provider(
            id: .init(rawValue: providerId),
            serverId: serverId,
            supportedConfigurationIdentifiers: supportedConfigurationIds,
            supportedPresetIds: supportedPresetIds,
            categoryName: categoryName,
            countryCode: countryCode,
            otherCountryCodes: otherCountryCodes,
            area: area
        )
        return VPNServer(provider: provider, hostname: hostname, ipAddresses: ipAddresses)
    }
}
