//
//  DomainMapper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/29/24.
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

struct DomainMapper {
    func provider(from entity: CDProviderV3) -> Provider? {
        guard let id = entity.providerId, let fullName = entity.fullName else {
            return nil
        }
        let metadata: [ModuleType: Provider.Metadata]
        if let encodedMetadata = entity.encodedMetadata {
            do {
                metadata = try JSONDecoder().decode([ModuleType: Provider.Metadata].self, from: encodedMetadata)
            } catch {
                return nil
            }
        } else if let supportedModuleTypes = entity.supportedModuleTypes?.components(separatedBy: ",") {
            metadata = supportedModuleTypes.reduce(into: [:]) {
                $0[ModuleType($1)] = .init()
            }
        } else {
            metadata = [:]
        }
        return Provider(
            id,
            description: fullName,
            metadata: metadata
        )
    }

    func cache(from entities: [CDProviderV3]) -> [ProviderID: ProviderCache] {
        let decoder = JSONDecoder()
        return entities.reduce(into: [:]) {
            guard let id = $1.providerId else {
                return
            }
            guard let cache = $1.cache else {
                return
            }
            do {
                $0[.init(rawValue: id)] = try decoder.decode(ProviderCache.self, from: cache)
            } catch {
                pp_log_g(.api, .error, "Unable to decode cache: \(error)")
            }
        }
    }

    func preset(from entity: CDProviderPresetV3) throws -> ProviderPreset? {
        guard let presetId = entity.presetId,
              let presetDescription = entity.presetDescription,
              let providerId = entity.providerId,
              let moduleType = entity.moduleType,
              let templateData = entity.templateData else {
            return nil
        }
        return ProviderPreset(
            providerId: .init(rawValue: providerId),
            presetId: presetId,
            description: presetDescription,
            moduleType: ModuleType(moduleType),
            templateData: templateData
        )
    }

    func server(from entity: CDProviderServerV3) throws -> ProviderServer? {
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
        let supportedModuleTypes = entity.supportedModuleTypes?.components(separatedBy: ",")
        let supportedPresetIds = entity.supportedPresetIds?.components(separatedBy: ",")
        let otherCountryCodes = entity.otherCountryCodes?.components(separatedBy: ",")
        let area = entity.area

        let metadata = ProviderServer.Metadata(
            providerId: .init(rawValue: providerId),
            categoryName: categoryName,
            countryCode: countryCode,
            otherCountryCodes: otherCountryCodes,
            area: area
        )
        return ProviderServer(
            metadata: metadata,
            serverId: serverId,
            hostname: hostname,
            ipAddresses: ipAddresses,
            supportedModuleTypes: supportedModuleTypes?.map(ModuleType.init(rawValue:)),
            supportedPresetIds: supportedPresetIds
        )
    }
}
