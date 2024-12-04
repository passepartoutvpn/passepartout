//
//  CoreDataMapper.swift
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
    func cdProvider(from provider: Provider, lastUpdate: Date?) throws -> CDProviderV3 {
        let entity = CDProviderV3(context: context)
        entity.providerId = provider.id.rawValue
        entity.fullName = provider.description
        entity.lastUpdate = lastUpdate
        entity.supportedConfigurationIds = provider.metadata.map(\.key).joined(separator: ",")
        entity.encodedMetadata = try JSONEncoder().encode(provider.metadata)
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
