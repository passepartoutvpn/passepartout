//
//  CoreDataMapper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
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

import CommonLibrary
import CoreData
import Foundation

struct CoreDataMapper {
    let context: NSManagedObjectContext

    @discardableResult
    func cdProvider(from provider: Provider, cache: Data?) throws -> CDProviderV3 {
        let entity = CDProviderV3(context: context)
        let encoder = JSONEncoder()

        entity.providerId = provider.id.rawValue
        entity.fullName = provider.description
        entity.cache = cache
        entity.supportedModuleTypes = provider.metadata.map(\.key.rawValue).joined(separator: ",")
        entity.encodedMetadata = try encoder.encode(provider.metadata)
        return entity
    }

    @discardableResult
    func cdServer(from server: ProviderServer) throws -> CDProviderServerV3 {
        let entity = CDProviderServerV3(context: context)
        let encoder = JSONEncoder()

        entity.serverId = server.serverId
        entity.hostname = server.hostname
        entity.ipAddresses = try server.ipAddresses.map {
            try encoder.encode($0)
        }
        entity.supportedModuleTypes = server.supportedModuleTypes?.map(\.rawValue).joined(separator: ",")
        entity.supportedPresetIds = server.supportedPresetIds?.joined(separator: ",")

        entity.providerId = server.metadata.providerId.rawValue
        entity.countryCode = server.metadata.countryCode
        entity.categoryName = server.metadata.categoryName
        entity.localizedCountry = server.metadata.countryCode.localizedAsRegionCode
        entity.otherCountryCodes = server.metadata.otherCountryCodes?.joined(separator: ",")
        entity.area = server.metadata.area

        return entity
    }

    @discardableResult
    func cdPreset(from preset: ProviderPreset) throws -> CDProviderPresetV3 {
        let entity = CDProviderPresetV3(context: self.context)
        entity.providerId = preset.providerId.rawValue
        entity.presetId = preset.presetId
        entity.presetDescription = preset.description
        entity.moduleType = preset.moduleType.rawValue
        entity.templateData = preset.templateData
        return entity
    }
}
