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

import CoreData
import Foundation
import PassepartoutKit

struct DomainMapper {
    func provider(from entity: CDProviderV3) -> Provider? {
        guard let id = entity.providerId, let fullName = entity.fullName else {
            return nil
        }
        let metadata: [String: Provider.Metadata]
        if let encodedMetadata = entity.encodedMetadata {
            do {
                metadata = try JSONDecoder().decode([String: Provider.Metadata].self, from: encodedMetadata)
            } catch {
                return nil
            }
        } else if let supportedConfigurationIds = entity.supportedConfigurationIds?.components(separatedBy: ",") {
            metadata = supportedConfigurationIds.reduce(into: [:]) {
                $0[$1] = .init()
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

    func lastUpdate(from entities: [CDProviderV3]) -> [ProviderID: Date] {
        entities.reduce(into: [:]) {
            guard let id = $1.providerId,
                  let lastUpdate = $1.lastUpdate else {
                return
            }
            $0[.init(rawValue: id)] = lastUpdate
        }
    }

    func preset(from entity: CDVPNPresetV3) throws -> AnyProviderPreset? {
        guard let presetId = entity.presetId,
              let presetDescription = entity.presetDescription,
              let providerId = entity.providerId,
              let configurationId = entity.configurationId,
              let template = entity.configuration else {
            return nil
        }

        let decoder = JSONDecoder()
        let endpoints = try entity.endpoints.map {
            try decoder.decode([EndpointProtocol].self, from: $0)
        } ?? []

        return AnyProviderPreset(
            providerId: .init(rawValue: providerId),
            presetId: presetId,
            description: presetDescription,
            endpoints: endpoints,
            configurationIdentifier: configurationId,
            template: template
        )
    }

    func server(from entity: CDVPNServerV3) throws -> ProviderServer? {
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

        let metadata = ProviderServer.Metadata(
            providerId: .init(rawValue: providerId),
            serverId: serverId,
            supportedConfigurationIdentifiers: supportedConfigurationIds,
            supportedPresetIds: supportedPresetIds,
            categoryName: categoryName,
            countryCode: countryCode,
            otherCountryCodes: otherCountryCodes,
            area: area
        )
        return ProviderServer(metadata: metadata, hostname: hostname, ipAddresses: ipAddresses)
    }
}
